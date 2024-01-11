

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:my_pr1/screens/auth/auth_service.dart';
import 'package:my_pr1/screens/auth/my_button.dart';
import 'package:my_pr1/screens/auth/square_tile.dart';
import 'package:my_pr1/screens/auth/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
   LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method
  void SignUserin() async{

    // show loading circle
    showDialog(context: context, builder: (context){
      return const Center(child: CircularProgressIndicator());
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword
    (email: emailController.text,
     password: passwordController.text);

     // pop the loading circle
     Navigator.pop(context);

    } on FirebaseAuthException catch(e) {
      // pop the loading circle
     Navigator.pop(context);
      
      // show error message 
      showErrorMessage(e.code);
    }

     
  }

  // wrong email message pop up

  void showErrorMessage( String message) {
    showDialog(context: context, builder: (context){
     
      return AlertDialog(
        backgroundColor: Colors.blue,
        title: Center(child: Text(message,style: TextStyle(color: Colors.grey[300]),)),);
    },);
  }
  

  @override
  Widget build(BuildContext context) {
   double w = MediaQuery.of(context).size.width;
   double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            
            
            children: [
            SizedBox(height: h*0.058,),
            Container(
               height: h*0.25,
               width: w,
               child: Column(
               children: [
               Icon(Icons.lock,size: h*0.11,color: Colors.indigo,),
               SizedBox(height: h*0.02),
               Text("Login",style: TextStyle(fontSize: 30,color: Colors.grey[900]),)
                ],
               ),
            ),
        
             
            Container(
              width: w,
              height: h*0.2,
              child: Column(
                  children: [
                   MyTextField(
                    controller:emailController ,
                    hintText: 'Enter your email id',
                    obsecureText: false,
                    preicon: Icon(Icons.email),
                   ),
                   SizedBox(height: h*0.009,),
                   MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obsecureText: true,
                    preicon: Icon(Icons.password),
                   ),SizedBox(height: h*0.01,),
              
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal :25.0),
                     child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Text('',style: TextStyle(color: Colors.grey[900])),
                       ],
                     ),
                   ),
                   
                   
        
                   
                    
                  ],
              ),
            ),

            
                   
             MyButton(btnText: 'Sign in',onTap: SignUserin,),
        
            SizedBox(height: h*0.04,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: Text('Or continue with',style: TextStyle(
                      color: Colors.grey[900],
                    ),),
                    
                  ),
            
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

             SizedBox(height: h*0.03,),
             SquareTile(imagePath: 'lib/assets/images/google.png',onTap: () => AuthService().signInWithGoogle(),),
             SizedBox(height: h*0.05,),

             Container(
              width:w,
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Not a member ?',style: TextStyle(color: Colors.grey[900],fontSize: 18),),
                  SizedBox(width: w*0.01,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text('Register now',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 18),)),
                ],
              ),
             ),


          
            
          ],),
        ),
      ),



      // 


    );
  }
}