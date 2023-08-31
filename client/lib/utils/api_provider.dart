import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

class ApiProvider {
  final Dio dio = Dio();

  Future get(String res) async {
    try {
      dio.options.extra['withCredentials'] = true;
      final response = await dio.get(
        "${dotenv.env['API_URL']}" "$res",
      );
      return response;
    } catch (err) {
      return;
    }
  }

  Future post(String res, [Map<String, dynamic>? data]) async {
    try {
      dio.options.extra['withCredentials'] = true;

      final response = await dio.post(
        "${dotenv.env['API_URL']}" "$res",
        data: data,
      );
      return response;
    } catch (err) {
      return err;
    }
  }

  Future<Map<String, dynamic>> login(
      String email, String password, context) async {
    if (email.isEmpty) {
      return {
        'success': false,
        'message': 'invalid email format',
      };
    }
    if (password.isEmpty || password.length < 3) {
      return {
        'success': false,
        'message': 'Password is wrong',
      };
    }
    final rawResponse = await post(
      "/login",
      {
        'email': email,
        'password': password,
      },
    );

    try {
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Invalid JSON response'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final rawResponse = await post(
        "/logout",
      );
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Logout failed'};
    }
  }

  Future<Map<String, dynamic>> allMaterialRequest() async {
    final rawResponse = await get("/all-material");
    try {
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Invalid Json Response'};
    }
  }

  Future<Map<String, dynamic>> materialAll() async {
    final rawResponse = await get("/material");
    try {
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Invalid Json Response'};
    }
  }

  Future<Map<String, dynamic>> viewRequest(String id) async {
    final rawResponse = await get(
      "/request?id=$id",
    );
    Map<String, dynamic> response = jsonDecode(rawResponse.toString());
    return response;
  }

  Future<Map<String, dynamic>> createRequest(
    String id,
    String product,
    String quantity,
    String unit,
  ) async {
    try {
      final rawResponse = await post("/create-request?id=$id", {
        "product_id": product,
        "qty_done": quantity,
        "product_uom_id": unit,
      });
      final Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      print(response);
      return response;
    } catch (error) {
      return {'error': 'Creating material request failed'};
    }
  }

  Future createMaterialRequest(String contactName, int contactId) async {
    try {
      final rawResponse = await post("/create-material", {
        'partner_id': contactId,
      });
      final Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (error) {
      return {'error': 'creating material request failed'};
    }
  }
}
