import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeController extends GetxController {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String teste = 'teste';

  void textToSpeech() {}
  void speech(File speechFile) async {
    await audioPlayer.play(DeviceFileSource(speechFile.path));
  }
}
