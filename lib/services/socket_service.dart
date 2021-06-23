import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServiceStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServiceStatus _serverStatus = ServiceStatus.Connecting;
  Socket _socket;

  ServiceStatus get serviceStatus => this._serverStatus;

  Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  void connect() async {
    print('🔸 Init socket configuration...');

    final token = await AuthService.getToken();

    // Dart client
    this._socket = io(
        'http://localhost:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableForceNew()
            .setExtraHeaders({'x-token': token}) // optional
            .build());

    this._socket.onConnect((_) {
      print('✅ Client connected...');
      this._serverStatus = ServiceStatus.Online;
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      print('❌ Client disconnected...');
      this._serverStatus = ServiceStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('new-message', (payload) {
    //   print('🔸 New message: $payload');
    // });

    this._socket.connect();
  }

  void disconnect() {
    this._socket.disconnect();
  }
}
