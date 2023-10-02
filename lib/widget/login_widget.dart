import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../page/forgot_password_page.dart';
import '../utils.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'TaskWhiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Kablammo',
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                    color: Colors.red.shade800),
              ),
              SizedBox(
                height: 60,
              ),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SofiaSans',
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontFamily: 'SofiaSans'),
                decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontFamily: 'SofiaSans'),
                    errorStyle: TextStyle(fontFamily: 'SofiaSans')),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontFamily: 'SofiaSans'),
                decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontFamily: 'SofiaSans'),
                    errorStyle: TextStyle(fontFamily: 'SofiaSans')),
                obscureText: true,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                      backgroundColor: Colors.red.shade800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: signIn,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'SofiaSans',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary,
                    fontFamily: 'MarckScript',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ForgotPasswordPage(),
                )),
              ),
              SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SofiaSans'),
                    text: 'no account?  ',
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignUp,
                          text: 'sign up',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).colorScheme.secondary,
                          ))
                    ]),
              )
            ],
          ),
        ),
      );

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
