import 'package:flutter/material.dart';
import 'package:my_pr1/screens/auth/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_pr1/screens/auth/profile_Page.dart';
import 'package:my_pr1/screens/myhome_page.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}


