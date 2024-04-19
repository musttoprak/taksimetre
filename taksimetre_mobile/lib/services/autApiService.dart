import 'dart:convert';

import 'package:dio/dio.dart';

import 'apiUrl.dart';

class AuthApiService {

  static Future<int?> login(String name, String password) async {
    Dio dio = Dio();
    print("$baseUrl/login?name=$name&password=$password");
    var result = await dio.get("$baseUrl/login?name=$name&password=$password");
    var data = jsonDecode(result.data);
    return data.toString() == "null" ? null : data;
  }

  static Future<bool> register(String name, String password) async {
    Dio dio = Dio();
    print("$baseUrl/register?name=$name&password=$password");
    var result = await dio.get("$baseUrl/register?name=$name&password=$password");
    var data = jsonDecode(result.data);
    return data == 1 ? true : false;
  }

}
