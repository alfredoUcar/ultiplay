import 'package:flutter/material.dart';

class Timer extends StatelessWidget {
  final String time;

  const Timer({
    Key? key,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.watch_later_outlined),
        Text(time),
      ],
    );
  }
}
