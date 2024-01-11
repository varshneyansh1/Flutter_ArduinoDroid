import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pr1/screens/bluetooth_devices.dart';
import 'package:my_pr1/screens/percent_indicator.dart';
import 'package:my_pr1/utils/Nav_Bar.dart';
import 'package:my_pr1/utils/smart_device_box.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';

import 'package:speech_to_text/speech_to_text.dart';

enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class myHomePage extends StatefulWidget {
  const myHomePage({super.key});

  @override
  State<myHomePage> createState() => _myHomePageState();
}

class _myHomePageState extends State<myHomePage> {
  BluetoothConnectionState _btStatus = BluetoothConnectionState.disconnected;
  BluetoothConnection? connection;
  String _messageBuffer = '';
  double? percentValue;
  String errorMsg = '';

  TextEditingController textFieldController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
 

  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions(); 
    initSpeech();
  }
   Future<void> requestBluetoothPermissions() async {
    try {
      await Permission.bluetooth.request();
    await Permission.location.request();
      await Permission.bluetoothScan.request();
    } catch (e) {
      print("Error requesting Bluetooth permissions: $e");
    }
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    print('Speech initialized: $_speechEnabled');
    setState(() {});
  }

  void _startListening() async {
     print('Start listening');
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
  
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }


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

  final double horizontalPadding = 20;
  final double verticalPadding = 25;

//list of smart devices
  List mySmartDevices = [
    // [smart DeviceName,iconPath,powerStatus ]
    ["Smart Light", 'lib/assets/icons/idea.png', false],
    ["Smart Buzzer", 'lib/assets/icons/bell.png', false],
    ["Weather", 'lib/assets/icons/cloudy.png', false],
    ["Terminal", 'lib/assets/icons/terminal.png', false],
  ];

  dialogPopUp(String textMsg) async {
    Completer<String?> completer = Completer();

    errorMsg = '';
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateForDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            scrollable: true,
            title: Text(textMsg, textAlign: TextAlign.center),
            contentPadding:
                EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            content: Column(
              children: [
                //text field
                SizedBox(
                  height: 45.0,
                  child: TextField(
                    controller: textFieldController,
                    decoration: InputDecoration(
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                ),
                // error text
                Visibility(
                  visible: errorMsg == '' ? false : true,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        errorMsg,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                // Save data button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width / 1.6,
                      50,
                    ),
                  ),
                  onPressed: () {
                    setStateForDialog(() {
                      if (textFieldController.text == "") {
                        errorMsg = "Enter the Message!";
                      } else {
                        errorMsg = '';
                        completer.complete(textFieldController.text);

                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Text('Submit'),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                // cancel button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    completer.complete(null); // Complete with null if canceled
                  },
                  child: Text('Cancel'),
                )
              ],
            ),
          );
        });
      },
    );

    return completer.future;
  }

//power button switched
  void powerSwitchChanged(bool value, int index) async {
    String text = '';
    if (value == true && index == 0) {
      text = 'onled';
    }
    if (value == false && index == 0) {
      text = 'ofled';
    }
    if (value == true && index == 1) {
      text = 'onbuz';
    }
    if (value == false && index == 1) {
      text = 'ofbuz';
    }
    if (value == true && index == 2) {
      text = 'ontmp';
    }
    if (value == false && index == 2) {
      text = 'oftmp';
    }
    if (value == true && index == 3) {
      text = 'onmsgg';
      String? text2 = await dialogPopUp("Enter the text");
      if (text2 != null) {
        text += text2;
        textFieldController.clear();
      } else {
        // User canceled the dialog
        return;
      }
    }
    if (value == false && index == 3) {
      text = 'ofmsgg';
    }
    
    setState(() {
      mySmartDevices[index][2] = value;
    });
    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;
      } finally {
        Future.delayed(const Duration(seconds: 4), () {
          setState(() {});
        });
      }
    }
  }

  void _onSpeechResult(result) {
    print('Speech result: $result');
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";

      // Check for specific commands and trigger actions accordingly
      if (_wordsSpoken.toLowerCase() == "turn on the led light") {
        // Trigger powerSwitchChanged with value=true and index=0
        powerSwitchChanged(true, 0);
      } else if (_wordsSpoken.toLowerCase() == "turn off the led light") {
        // Trigger powerSwitchChanged with value=false and index=0
        powerSwitchChanged(false, 0);
      } else if (_wordsSpoken.toLowerCase() == "turn on the alarm") {
        // Trigger powerSwitchChanged with value=true and index=1
        powerSwitchChanged(true, 1);
      } else if (_wordsSpoken.toLowerCase() == "turn off the alarm") {
        // Trigger powerSwitchChanged with value=false and index=1
        powerSwitchChanged(false, 1);
      } else if (_wordsSpoken.toLowerCase() == "display temperature") {
        // Trigger powerSwitchChanged with value=true and index=2
        powerSwitchChanged(true, 2);
      } else if (_wordsSpoken.toLowerCase() == "clear the screen") {
        // Trigger powerSwitchChanged with value=false and index=2
        powerSwitchChanged(false, 2);
      }

      // Add more conditions for other commands as needed
    });
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: NavBar(),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // container for welcome section
              SizedBox(
                height: h * 0.025,
              ),
              Container(
                height: h * 0.27,
                width: w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            return IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                icon: Image.asset('lib/assets/icons/menu.png',
                                    height: h * 0.05, color: Colors.grey[700]));
                          }),
                          IconButton(
                            icon: const Icon(Icons.settings_bluetooth),
                            onPressed: () async {
                              BluetoothDevice? device =
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const BluetoothDevices()));

                              if (device == null) return;

                              print('Connecting to device...');
                              
                              setState(() {
                                _btStatus = BluetoothConnectionState.connecting;
                              });
                              await Future.delayed(const Duration(seconds: 3));
                              BluetoothConnection.toAddress(device.address)
                                  .then((_connection) {
                                print('Connected to the device');
                                connection = _connection;
                                setState(() {
                                  _btStatus =
                                      BluetoothConnectionState.connected;
                                });

                                connection!.input!
                                    .listen(_onDataReceived)
                                    .onDone(() {
                                  setState(() {
                                    _btStatus =
                                        BluetoothConnectionState.disconnected;
                                  });
                                });
                              }).catchError((error) {
                                print('Cannot connect, exception occured');
                                print(error);

                                setState(() {
                                  _btStatus = BluetoothConnectionState.error;
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.001,
                    ),
                    Builder(
                      builder: (context) {
                        switch (_btStatus) {
                          case BluetoothConnectionState.disconnected:
                            return const PercentIndicator.disconnected();
                          case BluetoothConnectionState.connecting:
                            return PercentIndicator.connecting();
                          case BluetoothConnectionState.connected:
                            return PercentIndicator.connected(
                              percent: percentValue ?? 0,
                            );
                          case BluetoothConnectionState.error:
                            return const PercentIndicator.error();
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: h * 0.02,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                ),
              ),
              //container for grid
              Container(
                height: h * 0.7,
                width: w,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Devices',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.grey[800]),
                      ),
                      SizedBox(
                        height: h * 0.025,
                      ),

                      // grid view
                      Expanded(
                        child: GridView.builder(
                          itemCount: mySmartDevices.length,
                          padding: const EdgeInsets.all(2),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.3,
                          ),
                          itemBuilder: (context, index) {
                            return SmartDevicebox(
                              smartDeviceName: mySmartDevices[index][0],
                              iconPath: mySmartDevices[index][1],
                              powerOn: mySmartDevices[index][2],
                              onChanged: (value) =>
                                  powerSwitchChanged(value, index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Colors.black54,
        
      ),
    );
  }
}
