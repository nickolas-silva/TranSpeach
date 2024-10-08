import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

class HomeController extends GetxController {
  final textMessageController = TextEditingController().obs;

  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;
  AudioPlayer player = AudioPlayer();
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();

  RxBool isRecording = false.obs;
  String filePath = "";
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    PermissionStatus status = await Permission.microphone.request();
    // player.play(DeviceFileSource(
    //     "/data/user/0/com.example.transpeach/app_flutter/meu_audio.aac"));
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
    // Parar a gravação
    await audioRecorder.stopRecorder();
    // Fechar o gravador
    await audioRecorder.closeRecorder();
    isRecording.value = false;
    print('Áudio gravado: $filePath');
  }

  void startRecord() async {
    // Pedir permissão para usar o microfone
    PermissionStatus status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      // Obter diretório de armazenamento
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String path = '${appDocDir.path}/meu_audio.aac';
      // Iniciar gravação
      await audioRecorder.openRecorder();
      await audioRecorder.startRecorder(
          toFile: path, // Nome do arquivo de saída
          codec: Codec.aacADTS);
      isRecording.value = true;
      filePath = path;
    } else {
      print("Permissão de microfone negada");
    }
  }

  Future<String> convertToBase64(String filePath) async {
    // Ler o arquivo como bytes
    File file = File(filePath);
    List<int> fileBytes = await file.readAsBytes();

    // Converter bytes para Base64
    String base64String = base64Encode(fileBytes);
    return base64String;
  }
}
