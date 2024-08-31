import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:transpeach/app/controllers/home_controller.dart';
import 'package:transpeach/app/core/constants/default_const.dart';
import 'package:transpeach/app/core/constants/img_file.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TranSpeach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              ImgFile.logo,
              height: 30,
              width: 30,
            )
          ],
        ),
      ),
      body: Center(
        child: TextButton(
          child: const Text("Clica aqui pai"),
          onPressed: () => controller.textToSpeech(),
        ),
      ),
    );
  }
}
