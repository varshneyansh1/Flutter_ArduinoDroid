import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String btnText;
  final  Function()? onTap;


  const MyButton({super.key,
  required this.btnText,
  required this.onTap});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap ,
      child: Container(
       width: w,
       
       
       padding: const EdgeInsets.all(20),
       margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(8),
        ),
        child:Center(
          child: Text(btnText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),),
        ),
      ),
    );
  }
}