from flask import Flask, request, session, jsonify
from flask_cors import CORS


from flask_session import Session


from os import environ
import xmlrpc.client


app = Flask(__name__)


app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
app.config["SECRET_KEY"] = environ.get("SESSION_SECRET")
app.config["SESSION_COOKIE_SAMESITE"] = "None"
app.config["SESSION_COOKIE_SECURE"] = True
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 0


ses = Session(app)
CORS(app, supports_credentials=True)


def isAuth():
    if "uid" in session and "email" in session and "password" in session:
        return True
    return False


def query(uid, password, model, method, condition, fields):
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(environ.get("URL")),
    )
    return models.execute_kw(
        environ.get("DB"),
        uid,
        password,
        model,
        method,
        condition,
        {"fields": fields},
    )


def create(uid, password, model, fields):
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(
            environ.get("URL"),
        ),
    )

    return models.execute_kw(
        environ.get("DB"),
        uid,
        password,
        model,
        "create",
        [fields],
    )


def update(uid, password, model, fields):
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(
            environ.get("URL"),
        ),
    )

    return models.execute_kw(
        environ.get("DB"),
        uid,
        password,
        model,
        "write",
        fields,
    )


def create_move(uid, password, move_line_data):
    models = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))
    common = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))

    common.version()
    uid = common.authenticate(environ.get("DB"), environ.get("EMAIL"), password, {})

    if not uid:
        return {"error": "Authentication failed"}
    try:
        move_line_id = models.execute_kw(
            environ.get("DB"),
            uid,
            password,
            "stock.move.line",
            "create",
            [move_line_data],
        )

        return {
            "success": "Stock move line created successfully",
            "move_line_id": move_line_id,
        }
    except Exception as e:
        return {"error": str(e)}


@app.route("/login", methods=["POST"])
def log_in():
    common = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))

    common.version()

    uid = common.authenticate(
        environ.get("DB"),
        request.json.get("email"),
        request.json.get("password"),
        {},
    )
    session_email = request.json.get("email")
    session_uid = uid
    session_password = request.json.get("password")
    print("Before setting session variables:", session)
    if uid:
        session["uid"] = session_uid
        session["email"] = session_email
        session["password"] = session_password
    name = query(
        session["uid"],
        session["password"],
        "res.users",
        "search_read",
        [[["id", "=", session["uid"]]]],
        ["name"],
    )

    isAuth()
    services = query(
        session["uid"],
        session["password"],
        "stock.picking",
        "search_read",
        [],
        ["name", "partner_id", "state", "picking_type_id"],
    )

    response = {"name": name[0]["name"], "services": services}
    print("After setting session variables:", session)
    print("authentication:", session["uid"], session["password"])
    print(response)
    return jsonify(response), 200


@app.route("/name", methods=["GET"])
def get_name():
    name = query(
        session["uid"],
        session["password"],
        "res.users",
        "search_read",
        [[["id", "=", session["uid"]]]],
        ["name"],
    )

    response = {"name": name[0]["name"]}

    return jsonify(response), 200


@app.route("/")
def index():
    email = session.get("email")
    password = session.get("password")
    return f"<h1>HELLO {email}, {password}</h1>"


@app.route("/logout", methods=["POST"])
def log_out():
    session.pop("uid", None)
    session.pop("email", None)
    session.pop("password", None)
    return "Logged out successfully", 200


@app.route("/material", methods=["GET"])
def get_all():
    isAuth()

    response = {
        "services": query(
            session["uid"],
            session["password"],
            "stock.picking",
            "search_read",
            [],
            ["name", "partner_id", "state", "picking_type_id"],
        )
    }
    return jsonify(response), 200


@app.route("/all-material", methods=["GET"])
def get_all_material_request():
    isAuth()

    response = {
        "material": query(
            session["uid"],
            session["password"],
            "stock.picking",
            "search_read",
            [[["picking_type_id", "=", 15]]],
            ["name", "partner_id", "state", "picking_type_id"],
        )
    }
    return jsonify(response), 200


@app.route("/request", methods=["GET"])
def get_request():
    id = int(request.args["id"])
    picking_data = query(
        session["uid"],
        session["password"],
        "stock.picking",
        "search_read",
        [[["id", "=", id]]],
        [
            "name",
            "partner_id",
            "state",
            "picking_type_id",
        ],
    )

    move_line_data = query(
        session["uid"],
        session["password"],
        "stock.move.line",
        "search_read",
        [[["picking_id", "=", id]]],
        [
            "product_id",
            "qty_done",
            "product_uom_id",
            "company_id",
            "location_id",
            "location_dest_id",
        ],
    )

    response = {
        "request": picking_data,
        "move_lines": move_line_data,
    }

    return jsonify(response)


@app.route("/create-request", methods=["POST"])
def create_request():
    isAuth()
    uid = session.get("uid")
    password = session.get("password")
    id = int(request.args.get("id", 0))

    data = request.json
    move_line_data = {
        "picking_type_id": 15,
        "product_id": data.get("product_id"),
        "qty_done": data.get("qty_done"),
        "product_uom_id": data.get("product_uom_id"),
        "company_id": 1,
        "location_id": 4,
        "location_dest_id": 5,
    }

    try:
        created_move_line = create_move(uid, password, move_line_data)
        picking_data = query(
            uid,
            password,
            "stock.picking",
            "search_read",
            [[["id", "=", id]]],
            [
                "name",
                "partner_id",
                "state",
                "picking_type_id",
            ],
        )

        return (
            jsonify(
                {
                    "request": picking_data,
                    "created_move_line": created_move_line,
                }
            ),
            201,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/create-material", methods=["POST"])
def create_material():
    if not isAuth():
        return jsonify({"error": "Not Authenticated!"}), 401

    partner_id = request.json.get("partner_id")

    if not partner_id:
        return jsonify({"error": "partner_id is required"}), 400

    response = create(
        session["uid"],
        session["password"],
        "stock.picking",
        {
            "partner_id": partner_id,
            "picking_type_id": 15,
        },
    )

    print(response)

    return jsonify(response), 200


if __name__ == "__main__":
    app.run(debug=True)
