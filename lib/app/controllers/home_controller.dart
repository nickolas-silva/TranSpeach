import 'dart:io';

import 'package:get/get.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeController extends GetxController {
  String teste = 'teste';
}

void textToSpeech(String text) async {
// The speech request.
  File speechFile = await OpenAI.instance.audio.createSpeech(
    model: "tts-1",
    input: "Say my name is Anas",
    voice: "nova",
    responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
    outputDirectory: await Directory("speechOutput").create(),
    outputFileName: "anas",
  );

// The file result.
  print(speechFile.path);
}
