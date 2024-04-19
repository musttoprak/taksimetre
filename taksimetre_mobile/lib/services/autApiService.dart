import 'dart:convert';

import 'package:dio/dio.dart';

class AuthApiService {
  static const baseUrl = "http://192.168.195.1:6060";

  static Future<bool> login(String name, String password) async {
    Dio dio = Dio();
    print("$baseUrl/login?name=$name&password=$password");
    var result = await dio.get("$baseUrl/login?name=$name&password=$password");
    var data = jsonDecode(result.data);
    return data;
  }

  static Future<bool> register(String name, String password) async {
    Dio dio = Dio();
    print("$baseUrl/register?name=$name&password=$password");
    var result = await dio.get("$baseUrl/register?name=$name&password=$password");
    var data = jsonDecode(result.data);
    return data;
  }

}
