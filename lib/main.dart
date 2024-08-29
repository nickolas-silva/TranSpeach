import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transpeach/app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  OpenAI.apiKey = dotenv.env["OPEN_AI_API_KEY"]!;
  runApp(const TranSpeachApp());
}

class TranSpeachApp extends StatelessWidget {
  const TranSpeachApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TranSpeach',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.purple,
      ),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!),
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      getPages: AppPages().pages,
    );
  }
}
