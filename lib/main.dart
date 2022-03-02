import 'package:achat/controllers/firebase_auth_controller.dart';
import 'package:achat/views/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthController>(
            create: (_) => FirebaseAuthController())
      ],
      builder: (context, child) => MaterialApp(
        title: "Achat",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Baloo2",
          scaffoldBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
        ),
        home: MainScreen(),
      ),
    );
  }
}
