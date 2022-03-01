import 'package:achat/controllers/firebase_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        centerTitle: true,
      ),
      body: Container(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: () {
            context.read<FirebaseAuthController>().signOut();
          },
        ),
      ),
    );
  }
}
