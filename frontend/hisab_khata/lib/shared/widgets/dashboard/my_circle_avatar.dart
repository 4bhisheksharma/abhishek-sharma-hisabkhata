import 'package:flutter/material.dart';

class MyCircleAvatar extends StatelessWidget {
  const MyCircleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    //todo: just a placeholder yo UI aanusar baki nai chha garna

    return CircleAvatar(
      radius: 40,

      backgroundColor: Colors.grey[300],

      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }
}
