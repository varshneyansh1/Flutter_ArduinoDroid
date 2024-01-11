import 'package:flutter/material.dart';

class PercentIndicator extends StatelessWidget {
  final double? percent;
  final Color? color;
  final String? _message;
  const PercentIndicator.connected({super.key, required this.percent})
      : color = const Color.fromARGB(255, 98, 252, 103),
        _message = 'Connected';
  PercentIndicator.connecting({super.key})
      : percent = null,
        _message = 'Connecting...',
        color = const Color.fromARGB(255, 122, 192, 249);
  const PercentIndicator.disconnected({super.key})
      : percent = 1.0,
        _message = 'Disconnected',
        color = Colors.black87;
  const PercentIndicator.error({super.key})
      : percent = 1.0,
        _message = 'Error',
        color = Colors.red;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          height: h*0.12,
          width: w*0.3,
          child: CircularProgressIndicator(
            value: percent,
            color: color,
          ),
        ),
        SizedBox(
          height: h*0.12,
          width: w*0.3,
          child: Center(
            child: Text(
              _message != null
                  ? _message!
                  : '${((percent ?? 0) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
