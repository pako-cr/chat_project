import 'dart:io';

import 'package:chat_app/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _userWritting = false;

  List<ChatMessage> _messages = [];
  //   ChatMessage(text: 'Hola Mundo!', uid: '123'),
  //   ChatMessage(
  //       text:
  //           'Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! Hola Mundo! ',
  //       uid: '123'),
  //   ChatMessage(text: 'Hello World!', uid: '666'),
  //   ChatMessage(
  //       text:
  //           'Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! Hello World! ',
  //       uid: '666'),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text(
                'TT',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 15,
            ),
            SizedBox(height: 5),
            Text(
              'Francisco Córdoba',
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
      uid: '123',
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
  void dispose() {
    // TODO: Off del socket

    _messages.forEach((element) {
      element.animationController.dispose();
    });
    super.dispose();
  }
}
