import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    double h= MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300] ,
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.grey[900],
      ),

      body: ListView(
        children: [
          SizedBox(height:h*0.05),
          //profile pic
            Icon(Icons.person,size:72),

           SizedBox(height:h*0.05),

            Padding(
              padding: const EdgeInsets.only(left:25.0),
              child: Text('My Account',style: TextStyle(color:Colors.grey[600]),),
            ),
          //username
            
          //user email
          Text(currentUser.email!,
           textAlign: TextAlign.center,
           style: TextStyle(color:Colors.grey[700]),)

          
        ],
      ),
    );
  }
}