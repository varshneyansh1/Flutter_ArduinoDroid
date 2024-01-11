import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:my_pr1/screens/bluetooth_devices.dart';
import 'dart:convert';
enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

 class SmartDevicebox extends StatefulWidget {
  final String smartDeviceName;
  final String iconPath;
  final bool powerOn;
   final ValueChanged<bool> onChanged;

   SmartDevicebox({super.key,required this.smartDeviceName,required this.powerOn,required this.iconPath,required this.onChanged});

  @override
  State<SmartDevicebox> createState() => _SmartDeviceboxState();
}

class _SmartDeviceboxState extends State<SmartDevicebox> {

    BluetoothConnectionState _btStatus = BluetoothConnectionState.disconnected;
  BluetoothConnection? connection;
  String _messageBuffer = '';
  double? percentValue;
  bool _isWatering = false;

    void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    var message = '';
    if (~index != 0) {
      message = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // calculate percentage from message
    // analog 10 bit
    if (message.isEmpty) return; // to avoid fomrmat exception
    double? analogMessage = double.tryParse(message.trim());
    setState(() {
      var percent = (analogMessage ?? 0) / 1023;
      percentValue = 1 - percent; // inverse percent
    });
  }

  

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
   
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration:BoxDecoration(color: widget.powerOn?Colors.grey[900]:Colors.grey[350],
        borderRadius:BorderRadius.circular(24) ),
        padding:EdgeInsets.symmetric(vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
                  // icon 
           Image.asset(widget.iconPath,height:65,color: widget.powerOn? Colors.white: Colors.black),
    
           // smart device name + switch
           Row(
             children: [
               Expanded(child: Padding(
                 padding: const EdgeInsets.only(left:15.0),
                 child: Text(widget.smartDeviceName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: h*0.016,color: widget.powerOn? Colors.white: Colors.black ),
                 ),
               )),
               Transform.rotate(
               angle: 0,
                 child:CupertinoSwitch(
                  
              value: widget.powerOn,
              onChanged: (value) async {
                widget.onChanged(value);

                String text = 'water';

                if (value) {
                  setState(() => _isWatering = true);

                if (text.isNotEmpty) {
                  try {
                    connection!.output
                        .add(Uint8List.fromList(utf8.encode("$text\r\n")));
                    await connection!.output.allSent;
                  } finally {
                    Future.delayed(const Duration(seconds: 4), () {
                      setState(() => _isWatering = false);
                    });
                  }
                }
                }
              },
            ),
               )
             ],
           )
    
          ]
           
    
        ),
      ),
    );
  }
}