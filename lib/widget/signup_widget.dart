import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
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
          child: Form(
            key: formKey,
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
                  'Join Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SofiaSans'),
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
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontFamily: 'SofiaSans'),
                  decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(fontFamily: 'SofiaSans'),
                      errorStyle: TextStyle(fontFamily: 'SofiaSans')),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter minimum 6 characters'
                      : null,
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
                    onPressed: signUp,
                    child: Text(
                      'Register',
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
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'SofiaSans',
                      ),
                      text: 'Already have an account? ',
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignIn,
                          text: 'Log In',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => Center(child: CircularProgressIndicator(),)
    // );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
