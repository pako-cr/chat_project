import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _userWritting = false;

  ChatService chatService;
  SocketService socketService;
  AuthService authService;

  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('private-message', _listenMessages);

    _getChatMessages(this.chatService.userTo.uid);
  }

  @override
  void dispose() {
    _messages.forEach((element) {
      element.animationController.dispose();
    });

    this.socketService.socket.off('private-message');
    super.dispose();
  }

  void _listenMessages(dynamic payload) {
    print('New message: $payload');

    final newMessage = ChatMessage(
      text: payload['message'],
      uid: payload['from'],
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
      ),
    );

    this._messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      this._userWritting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userTo = chatService.userTo;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text(
                userTo.name.substring(0, 2),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 15,
            ),
            SizedBox(height: 5),
            Text(
              userTo.name,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            )
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 2),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
                itemCount: _messages.length,
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              color: Colors.white,
              height: 50,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: this._textController,
                onSubmitted: _handleSubmit,
                onChanged: (String text) {
                  setState(() {
                    this._userWritting =
                        (text.trim().length > 0) ? true : false;
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Send message...'),
                focusNode: this._focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Send'),
                      onPressed: this._userWritting
                          ? () => _handleSubmit(_textController.text.trim())
                          : null)
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            icon: Icon(Icons.send),
                            onPressed: this._userWritting
                                ? () =>
                                    _handleSubmit(_textController.text.trim())
                                : null),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String text) {
    if (text.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text.trim(),
      uid: authService.user.uid,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
      ),
    );

    this._messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      this._userWritting = false;
    });

    this.socketService.emit('private-message', {
      'from': this.authService.user.uid,
      'to': this.chatService.userTo.uid,
      'message': text
    });
  }

  void _getChatMessages(String userToId) async {
    List<Message> messages = await this.chatService.getChat(userToId);

    final history = messages.map((m) => ChatMessage(
          text: m.message,
          uid: m.from,
          animationController: new AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 1000),
          )..forward(),
        ));

    setState(() {
      this._messages.insertAll(0, history);
    });
  }
}
