

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_pr1/screens/auth/auth_service.dart';
import 'package:my_pr1/screens/auth/my_button.dart';
import 'package:my_pr1/screens/auth/square_tile.dart';
import 'package:my_pr1/screens/auth/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
   RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final firstNameController=TextEditingController();
  final lastNameController=TextEditingController();
  

  // sign user up method
  void SignUserUp() async{

    // show loading circle
    showDialog(context: context, builder: (context){
      return const Center(child: CircularProgressIndicator());
    });
              // try creating the user 
    try {
     // check if password is confirmed
     if (passwordController.text==confirmpasswordController.text ){
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text,);
      // add user deatils
      addUserDetails(firstNameController.text, lastNameController.text, emailController.text);
      // pop the loading circle
     Navigator.pop(context);


     }else {
      //show error message
      // pop the loading circle
     Navigator.pop(context);
      showErrorMessage("Password don't match!");
         
     }

     

    } on FirebaseAuthException catch(e) {
      // pop the loading circle
     Navigator.pop(context);
      
      // show error message 
      showErrorMessage(e.code);
    }

     
  }
  Future addUserDetails(String firstName,String lastname,String email) async{
    await FirebaseFirestore.instance.collection('users').add({
      'first name': firstName,
      'last name': lastname,
      'email': email,
    });
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
            SizedBox(height: h*0.04,),
            Container(
               height: h*0.17,
               width: w,
               child: Column(
               children: [
               Icon(Icons.lock,size: h*0.08,color: Colors.indigo,),
               SizedBox(height: h*0.02,),
               Text("Create an Account",style: TextStyle(fontSize: 30,color: Colors.grey[900]),)
                ],
               ),
            ),
        
             
            Container(
              width: w,
              height: h*0.42,
              child: Column(
                  children: [
                    // first name
                    MyTextField(
                    controller:firstNameController ,
                    hintText: 'First Name',
                    obsecureText: false,
                    preicon: Icon(Icons.person),
                   ), 
                   SizedBox(height: h*0.009,),
                    // last name
                    MyTextField(
                    controller:lastNameController ,
                    hintText: 'Last Name',
                    obsecureText: false,
                    preicon: Icon(Icons.person_2_rounded),
                   ), 
                   SizedBox(height: h*0.009,),
                   MyTextField(
                    controller:emailController ,
                    hintText: 'Enter your email id',
                    obsecureText: false,
                    preicon: Icon(Icons.email),
                   ), 
                   // password textfield
                   SizedBox(height: h*0.009,),
                   MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obsecureText: true,
                    preicon: Icon(Icons.password),
                   ),
                   // confirm password
                   SizedBox(height: h*0.009,),
                   MyTextField(
                    controller: confirmpasswordController,
                    hintText: 'Confirm Password',
                    obsecureText: true,
                    preicon: Icon(Icons.password),
                   ),
                   
                   
              
                   
                   
                   
        
                   
                    
                  ],
              ),
            ),

            
       
             MyButton(btnText: 'Sign Up',onTap: SignUserUp,),


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

             SizedBox(height: h*0.02,),
             SquareTile(imagePath: 'lib/assets/images/google.png',onTap: () => AuthService().signInWithGoogle(),),
             SizedBox(height: h*0.01,),

             Container(
              width:w,
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Already have an account ?',style: TextStyle(color: Colors.grey[900],fontSize: 18),),
                  SizedBox(width: w*0.01,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text('Login now',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 18),)),
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