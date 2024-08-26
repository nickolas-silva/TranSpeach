import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transpeach/app/routes/app_pages.dart';

void main() {
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
      builder: (context, child) => 
        MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      getPages: AppPages().pages,
    );
  }
}