import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:transpeach/app/model/message.dart';
import 'package:transpeach/app/service/messageService.dart';

class HomeController extends GetxController {
  final textMessageController = TextEditingController();

  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;
  AudioPlayer player = AudioPlayer();
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();

  final messageText =
      "".obs; // Variável para verificar se o campo de texto está vazio
  RxBool isRecording = false.obs;
  String filePath = "";
  MessageService messageService = MessageService();
  var messages = [].obs;

  void saveMessage(Message message) async {
    try {
      Message newMessage = await messageService.save(message);
      print(newMessage);
      messages.clear();
      messages.addAll(await messageService.getAll());
    } catch (ex) {
      rethrow;
    }
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    PermissionStatus status = await Permission.microphone.request();
    // player.play(DeviceFileSource(
    //     "/data/user/0/com.example.transpeach/app_flutter/meu_audio.mp4"));
    messages.value = await messageService.getAll();
    messages.refresh();

    textMessageController.addListener(() {
      messageText.value = textMessageController.text;
    });
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

  void stopRecord() async {
    // Parar a gravação
    String? path = await audioRecorder.stopRecorder();
    await audioRecorder.closeRecorder();
    filePath = path!;
    isRecording.value = false;
    print('Áudio gravado: $filePath');
  }

  void startRecord() async {
    // Pedir permissão para usar o microfone
    PermissionStatus status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      // Obter diretório de armazenamento
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String path = '${appDocDir.path}/meu_audio.wav';
      // Iniciar gravaçãoR
      await audioRecorder.openRecorder();
      await audioRecorder.startRecorder(codec: Codec.pcm16WAV, toFile: path);
      isRecording.value = true;
      filePath = path;
    } else {
      print("Permissão de microfone negada");
    }
  }

  void speechToText(String path) async {
    final uri = Uri.parse(
        'http://192.168.0.112:3000/speech-to-text'); // Altere para seu URL de produção
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('audio', path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Transcrição: $responseString');
      } else {
        print('Erro: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar: $e');
    }
  }
}
