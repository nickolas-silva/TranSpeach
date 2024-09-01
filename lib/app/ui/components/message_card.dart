import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transpeach/app/model/message.dart';

class MessageCard extends StatelessWidget {
  Message message;

  MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(message.text),
          Builder(builder: (context) {
            if (message.isTranslated == true) {
              return Column(
                children: [
                  Text(message.translatedText!),
                  ElevatedButton(onPressed: (){}, child: const Text(">"))
                ],
              );
            }
            
            return const SizedBox(height: 10,);
          }),
          Text('${message.sendAt.hour}:${message.sendAt.minute}')
        ],
      ),
    );
  }

}