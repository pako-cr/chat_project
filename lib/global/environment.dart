import 'dart:io';

class Environment {
  static String apiUrl =
      Platform.isAndroid ? 'http://localhost:3000/api' : 'localhost:3000';

  static String socketUrl =
      Platform.isAndroid ? 'http://localhost:3000' : 'http://localhost:3000';
}
