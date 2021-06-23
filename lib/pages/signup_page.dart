import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/helpers/show_alert.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widgets/auth_labels.dart';
import 'package:chat_app/widgets/auth_logo.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:chat_app/widgets/terms_and_conditions.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AuthenticationLogo(
                  title: 'Register',
                ),
                _Form(),
                AuthenticationLabels(
                    title: 'Already have an account?',
                    subtitle: 'Sign in!',
                    callback: () {
                      Navigator.pop(context);
                    }),
                TermsAndConditions()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nicknameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _validForm = false;

  void validForm() {
    setState(() {
      this._validForm = this.nicknameTextController.text.isNotEmpty &&
          this.emailTextController.text.isNotEmpty &&
          this.passwordTextController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          CustomInput(
            icon: Icons.account_circle_outlined,
            placeholder: 'Nickname',
            textController: nicknameTextController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => this.validForm(),
          ),
          CustomInput(
            icon: Icons.email_outlined,
            placeholder: 'Email',
            textController: emailTextController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => this.validForm(),
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Password',
            textController: passwordTextController,
            keyboardType: TextInputType.visiblePassword,
            isPassword: true,
            onChanged: (_) => this.validForm(),
          ),
          CustomButton(
            title: 'Sign Up',
            onPressed: (authService.authInProgress || !this._validForm)
                ? null
                : () async {
                    FocusScope.of(context).unfocus();

                    final signUpResponse = await authService.signUp(
                        nicknameTextController.text.trim(),
                        emailTextController.text.trim(),
                        passwordTextController.text.trim());

                    if (signUpResponse.toString().isEmpty) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(context, 'users');
                    } else {
                      showAlert(context, 'Error', signUpResponse);
                    }
                  },
            enabled: (authService.authInProgress || !this._validForm),
          ),
        ],
      ),
    );
  }
}
