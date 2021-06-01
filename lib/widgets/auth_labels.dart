import 'package:flutter/material.dart';

class AuthenticationLabels extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function callback;

  const AuthenticationLabels({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            this.title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: callback,
            child: Text(
              this.subtitle,
              style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
