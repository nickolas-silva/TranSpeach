import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class HomeController extends GetxController {
  final textMessageController = TextEditingController().obs;

  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;
  AudioPlayer player = AudioPlayer();
  AudioRecorder audioRecorder = AudioRecorder();

  RxBool isRecording = false.obs;
  String filePath = "";
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    PermissionStatus status = await Permission.microphone.request();
  }

  void selectLanguage(String? value) {
    _selectedLanguage = value;
    update();
  }

  void textToSpeech(String frase) async {
    var url = Uri.parse(
        "https://rw5nftwea2.execute-api.us-east-1.amazonaws.com/converter"); // url da minha função lambda

    var response = await http.post(url,
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: json.encode({"phrase": frase}));
    // na response, vai haver o link do aúdio que tá no bucket da aws
    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      String urlToAudio = json["url_to_audio"];
      player.setSource(UrlSource(urlToAudio));
      player.resume();
    } else {
      print("Erro na requisição.");
    }
  }

  void speechToText() async {}
  void stopRecord() async {
    final path =
        await audioRecorder.stop(); // Retorna o caminho do arquivo de áudio
    isRecording.value = false;
    print('Áudio gravado: $path');
  }

  void startRecord() async {
    // Pedir permissão para usar o microfone
    PermissionStatus status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      // Verificar se tem permissão
      if (await audioRecorder.hasPermission()) {
        // Obter diretório de armazenamento
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String path = '${appDocDir.path}/meu_audio.m4a';
        // Iniciar gravação
        await audioRecorder.start(
          const RecordConfig(),
          path: path, // Caminho onde o arquivo de áudio será salvo
        );
        isRecording.value = true;
        filePath = path;
      }
    } else {
      print("Permissão de microfone negada");
    }
  }
}
