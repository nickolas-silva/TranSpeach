import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transpeach/app/model/message.dart';

class MessageCard extends StatelessWidget {
  Message message;

  MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Align(
        alignment:
            message.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
          color: message.isSender ? Colors.blue[100] : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: message.isSender ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
