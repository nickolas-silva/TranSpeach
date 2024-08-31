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
      body: Stack(
        children: [
          //Messages Container
          Container(
            height: Get.height,
            width: Get.width,
            color: backgroundColor,
          ),

          //Inputas Sheet
          Positioned(
            bottom: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: Container(
                height: 225,
                width: Get.width,
                decoration: const BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Traduzir para:',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}