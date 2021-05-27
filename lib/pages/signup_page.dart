import 'package:chat_app/widgets/auth_logo.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:chat_app/widgets/auth_labels.dart';
import 'package:chat_app/widgets/terms_and_conditions.dart';
import 'package:flutter/material.dart';

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
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _validForm = false;

  void validateForm() {
    this.emailTextController.addListener(() {
      this._validForm = this.emailTextController.text.isNotEmpty &&
          this.passwordTextController.text.isNotEmpty;
    });

    this.passwordTextController.addListener(() {
      this._validForm = this.passwordTextController.text.isNotEmpty &&
          this.emailTextController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    validateForm();
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          CustomInput(
            icon: Icons.account_circle_outlined,
            placeholder: 'Nickname',
            textController: emailTextController,
            keyboardType: TextInputType.emailAddress,
          ),
          CustomInput(
            icon: Icons.email_outlined,
            placeholder: 'Email',
            textController: emailTextController,
            keyboardType: TextInputType.emailAddress,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Password',
            textController: passwordTextController,
            keyboardType: TextInputType.visiblePassword,
            isPassword: true,
          ),
          // CustomInput(
          //   icon: Icons.lock_outline,
          //   placeholder: 'Re-enter Password',
          //   textController: passwordTextController,
          //   keyboardType: TextInputType.visiblePassword,
          //   isPassword: true,
          // ),
          CustomButton(
            title: 'Register',
            onPressed: () {
              print('Register button pressed!');
            },
            enabled: _validForm,
          ),
        ],
      ),
    );
  }
}
