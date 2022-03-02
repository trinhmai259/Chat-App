import 'package:achat/controllers/firebase_auth_controller.dart';
import 'package:achat/resources/widgets/auth/body_sign_in.dart';
import 'package:achat/resources/widgets/auth/header_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  HeaderSignIn(),
                  BodySignIn(
                      emailEditingController: emailEditingController,
                      passwordEditingController: passwordEditingController),
                ],
              ),
            ),
          ),
        ),
        if (context.watch<FirebaseAuthController>().isLoading)
          Center(
            child: CircularProgressIndicator(),
          )
      ],
    );
  }
}
