import 'package:flutter/foundation.dart';

class Message {
  int? id = 0;
  final String text;
  final DateTime sendAt;

  Message({this.id, required this.text, required this.sendAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(id: json['id'], text: json['text'], sendAt: json['sendAt']);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'sendAt': sendAt
  };
}