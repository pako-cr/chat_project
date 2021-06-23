import 'package:chat_app/models/users_response.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';

class UsersServices {
  Future<List<User>> getUsers() async {
    try {
      var uri = Uri.http('${Environment.apiUrl}', '/api/users');

      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken(),
        },
      );

      final usersResponse = usersResponseFromJson(resp.body);

      return usersResponse.users;
    } catch (ex) {
      print('Error getting users information. Description: $ex');
      return [];
    }
  }
}
