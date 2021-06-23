import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/signup_response.dart';
import 'package:chat_app/models/user.dart';

class AuthService with ChangeNotifier {
  User user;
  bool _authInProgress = false;

  bool get authInProgress => this._authInProgress;

  set authInProgress(bool inProgress) {
    this._authInProgress = inProgress;
    notifyListeners();
  }

  final _storage = new FlutterSecureStorage();

  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  // static Future<void> deleteToken() async {
  //   final _storage = new FlutterSecureStorage();
  //   await _storage.delete(key: 'token');
  // }

  static Future<void> logout() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future signUp(String nickname, String email, String password) async {
    this._authInProgress = true;
    notifyListeners();

    final data = {'name': nickname, 'email': email, 'password': password};

    var uri = Uri.http('${Environment.apiUrl}', '/api/login/new/');

    final resp = await http.post(
      uri,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    this._authInProgress = false;
    notifyListeners();

    if (resp.statusCode == 200) {
      final signUpResponse = signUpResponseFromJson(resp.body);
      this.user = signUpResponse.user;
      await this._saveToken(signUpResponse.token);

      return '';
    }

    final respBody = jsonDecode(resp.body);
    return respBody['msg'];
  }

  Future<bool> login(String email, String password) async {
    this._authInProgress = true;
    notifyListeners();

    final data = {'email': email, 'password': password};

    var uri = Uri.http('${Environment.apiUrl}', '/api/login/');

    final resp = await http.post(
      uri,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    this._authInProgress = false;
    notifyListeners();

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.user = loginResponse.user;
      await this._saveToken(loginResponse.token);

      return true;
    }

    return false;
  }

  Future isLogedIn() async {
    final token = await this._storage.read(key: 'token');

    var uri = Uri.http('${Environment.apiUrl}', '/api/login/renew/');

    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token,
      },
    );

    this._authInProgress = false;
    notifyListeners();

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.user = loginResponse.user;
      await this._saveToken(loginResponse.token);

      return true;
    }

    this.deleteToken();
    return false;
  }

  Future _saveToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future deleteToken() {
    // Delete value
    return this._storage.delete(key: 'token');
  }
}
