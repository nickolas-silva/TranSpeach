import 'package:flutter/foundation.dart';

class Message {
  int? id = 0;
  final String text;
  final DateTime sendAt;
  bool? isTranslated = false;
  String? translatedText;

  Message({this.id, required this.text, required this.sendAt, this.translatedText, this.isTranslated});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        text: json['text'],
        translatedText: json['translatedText'],
        sendAt: DateTime.parse(json['sendAt']),
        isTranslated: json['isTranslated']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'sendAt': sendAt.toString(),
    'translatedText': translatedText,
    'isTranslated': isTranslated
  };

  @override
  String toString() {
    return 'Message{id: $id, text: $text, sendAt: $sendAt, isTranslated: $isTranslated, translatedText: $translatedText}';
  }
}