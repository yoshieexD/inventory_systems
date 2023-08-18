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


@app.route("/")
def index():
    uid = session.get("uid")
    password = session.get("password")
    return f"<h1>HELLO {uid}, {password}</h1>"


# @app.route("/test-session", methods=["POST"])
# def test_session():
#     data = request.json
#     session["test_variable"] = data.get("value")
#     return "Session variable set successfully"


# @app.route("/get-test-session")
# def get_test_session():
#     value = session.get("test_variable")
#     return f"Session variable value: {value}"


# @app.route("/get-session", methods=["GET"])
# def get_session():
#     email = session.get("email")
#     password = session.get("password")
#     print(email, password)
#     return f"<h1>{email}</h1>, <h1>{password}</h1>"


@app.route("/logout", methods=["POST"])
def log_out():
    session.pop("uid", None)
    session.pop("email", None)
    session.pop("password", None)
    return "Logged out successfully", 200


@app.route("/material", methods=["GET"])
def get_all():
    common = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))

    uid = common.authenticate(
        environ.get("DB"), environ.get("EMAIL"), environ.get("PASSWORD"), {}
    )

    if uid:
        session["uid"] = uid
        session["email"] = environ.get("EMAIL")
        session["password"] = environ.get("PASSWORD")

        uid = session.get("uid")
        password = session.get("password")
        if uid and password:
            print("UID:", uid)
            print("Password:", password)

            response = {
                "services": query(
                    uid,
                    password,
                    "stock.picking",
                    "search_read",
                    [],
                    ["name", "partner_id", "state", "picking_type_id"],
                )
            }
            return jsonify(response), 200
        else:
            return "Not Authenticated!", 400
    else:
        return "Authentication Failed!", 401


@app.route("/all-material", methods=["GET"])
def get_all_material_request():
    common = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))

    uid = common.authenticate(
        environ.get("DB"), environ.get("EMAIL"), environ.get("PASSWORD"), {}
    )

    if uid:
        session["uid"] = uid
        session["email"] = environ.get("EMAIL")
        session["password"] = environ.get("PASSWORD")

        uid = session.get("uid")
        password = session.get("password")
        if uid and password:
            response = {
                "material": query(
                    uid,
                    password,
                    "stock.picking",
                    "search_read",
                    [[["picking_type_id", "=", 15]]],
                    ["name", "partner_id", "state", "picking_type_id"],
                )
            }
            return jsonify(response), 200
        else:
            return "Not Authenticated!", 400
    else:
        return "Authentication Failed!", 401


@app.route("/request", methods=["GET"])
def get_request():
    common = xmlrpc.client.ServerProxy("{}/xmlrpc/2/common".format(environ.get("URL")))

    uid = common.authenticate(
        environ.get("DB"), environ.get("EMAIL"), environ.get("PASSWORD"), {}
    )

    id = int(request.args["id"])
    if uid:
        session["uid"] = uid
        session["email"] = environ.get("EMAIL")
        session["password"] = environ.get("PASSWORD")

        uid = session.get("uid")
        password = session.get("password")
        if uid and password:
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

            move_line_data = query(
                uid,
                password,
                "stock.move.line",
                "search_read",
                [[["picking_id", "=", id]]],
                [
                    "product_id",
                    "qty_done",
                    "product_uom_id",
                ],
            )

            response = {
                "request": picking_data,
                "move_lines": move_line_data,
            }
            print("request", picking_data)
            print("move_lines", move_line_data)
            return jsonify(response)


if __name__ == "__main__":
    app.run(debug=True)
