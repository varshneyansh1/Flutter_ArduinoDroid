import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pr1/screens/auth/home_page.dart';
import 'package:my_pr1/screens/auth/login_or_register_page.dart';
import 'package:my_pr1/screens/myhome_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder<User?>(
        stream:FirebaseAuth.instance.authStateChanges() ,
        builder: (context,snapshot){
          // user is logged in 
          if (snapshot.hasData){
            return myHomePage();
          }

          // user is not logged in
          else {
            return LoginOrRegisterPage();
          }


        },
        )
    );
  }
}