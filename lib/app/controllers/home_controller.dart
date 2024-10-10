import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

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
    //     "/data/user/0/com.example.transpeach/app_flutter/meu_audio.mp4"));
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
      String path = '${appDocDir.path}/meu_audio.aac';
      // Iniciar gravação
      await audioRecorder.openRecorder();
      await audioRecorder.startRecorder(codec: Codec.aacADTS, toFile: path);
      isRecording.value = true;
      filePath = path;
    } else {
      print("Permissão de microfone negada");
    }
  }

  void upload() async {
    try {
      player.play(DeviceFileSource(filePath));
      final File audioFile = File(filePath);
      final String base64Audio = await convertToBase64(filePath);
      print(audioFile.uri.pathSegments.last);
      // Criar o cabeçalho com o nome do arquivo
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'file-name': audioFile.uri.pathSegments.last, // Pega o nome do arquivo
      };

      // Criar o corpo da requisição
      final Map<String, dynamic> body = {
        'body': base64Audio,
      };

      // Enviar a requisição POST
      final response = await http.post(
        Uri.parse(
            "https://4cpr8ijhx0.execute-api.us-east-1.amazonaws.com/upload"),
        headers: headers,
        body: jsonEncode(body),
      );

      // Verificar a resposta
      if (response.statusCode == 200) {
        print('Áudio enviado com sucesso: ${response.body}');
      } else {
        print(
            'Falha ao enviar áudio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao enviar áudio: $e');
    }
  }

  void uploadAudio(String base64Audio) async {
    print("Base64 Audio: $base64Audio"); // Verifique o valor do áudio em Base64

    var uri = Uri.parse(
        "https://4cpr8ijhx0.execute-api.us-east-1.amazonaws.com/transcribe");

    // Cria o cabeçalho e o corpo da requisição
    var request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['file-name'] = 'meu_audio.aac' // Nome do arquivo
      ..body = jsonEncode({
        'body': base64Audio,
      });
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Transcrição bem-sucedida!');
      } else {
        print('Falha na transcrição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar para Lambda: $e');
    }
  }

  void speechToText() async {
    String base64Audio = await convertToBase64(filePath);
    print('Audio em Base64: $base64Audio');

    uploadAudio(base64Audio);
  }

  Future<String> convertToBase64(String filePath) async {
    // Ler o arquivo como bytes
    print(filePath);
    File file = File(filePath);
    List<int> fileBytes = await file.readAsBytes();

    // Converter bytes para Base64
    String base64String = base64Encode(fileBytes);
    return base64String;
  }
}
