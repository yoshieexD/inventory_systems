from flask import Flask, request, session, jsonify
from flask_cors import CORS


from flask_session import Session


from os import environ
import xmlrpc.client


app = Flask(__name__)


app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
app.config["SECRET_KEY"] = environ.get("SESSION_SECRET")


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


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


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

    if uid:
        session["uid"] = uid
        session["email"] = request.json.get("email")
        session["password"] = request.json.get("password")

    isAuth()

    name = query(
        session["uid"],
        session["password"],
        "res.users",
        "search_read",
        [[["id", "=", session["uid"]]]],
        ["name"],
    )

    services = query(
        session["uid"],
        session["password"],
        "stock.picking",
        "search_read",
        [],
        ["name", "partner_id", "state", "picking_type_id"],
    )

    print("services in login", services)

    response = {"name": name[0]["name"], "services": services}

    print(response)

    return jsonify(response), 200


@app.route("/logout", methods=["POST"])
def log_out():
    session.pop("uid", None)
    session.pop("email", None)
    session.pop("password", None)
    return "Logged out successfully", 200


# @app.route("/all-tasks", methods=["GET"])
# def get_all_tasks():
#     isAuth()

#     response = {
#         "services": query(
#             session["uid"],
#             session["password"],
#             "project.task",
#             "search_read",
#             [],
#             [
#                 "name",
#                 "partner_id",
#                 "project_id",
#                 "user_ids",
#             ],
#         )
#     }

#     return jsonify(response), 200


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
                "service": query(
                    uid,
                    password,
                    "stock.picking",
                    "search_read",
                    [[["picking_type_id", "=", 15]]],
                    ["name", "partner_id", "state", "picking_type_id"],
                )
            }
            print("sessionuid:test", session["uid"])
            print(response)
            print("sessionpassword:test", session["password"])
            return jsonify(response), 200
        else:
            return "Not Authenticated!", 400
    else:
        return "Authentication Failed!", 401


# @app.route("/my-tasks", methods=["GET"])
# def get_my_tasks():
#     isAuth()

#     response = {
#         "services": query(
#             session["uid"],
#             session["password"],
#             "project.task",
#             "search_read",
#             [[["user_ids", "=", session["uid"]]]],
#             [
#                 "name",
#                 "partner_id",
#                 "project_id",
#                 "user_ids",
#             ],
#         )
#     }

#     return jsonify(response), 200


if __name__ == "__main__":
    app.run(debug=True)
