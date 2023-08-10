import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiProvider {
  final Dio dio = Dio();

  Future _get(String res) async {
    try {
      dio.options.extra['withCredentials'] = true;
      final response = await dio.get(
        "${dotenv.env['API_URL']}" "$res",
      );
      print(response);
      return response;
    } catch (err) {
      return;
    }
  }

  Future _post(String res, [Map<String, dynamic>? data]) async {
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
    final rawResponse = await _post(
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

  Future<Map<String, dynamic>> getAllTasks() async {
    final rawResponse = await _get(
      "/all-tasks",
    );

    try {
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Invalid JSON response'};
    }
  }

  Future<Map<String, dynamic>> getMyTasks() async {
    final rawResponse = await _get(
      "/my-tasks",
    );

    try {
      Map<String, dynamic> response = jsonDecode(rawResponse.toString());
      return response;
    } catch (e) {
      return {'error': 'Invalid JSON response'};
    }
  }
}
