import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:transpeach/app/controllers/home_controller.dart';
import 'package:transpeach/app/core/constants/default_const.dart';
import 'package:transpeach/app/core/constants/img_file.dart';
import 'package:transpeach/app/model/message.dart';
import 'package:transpeach/app/service/messageService.dart';
import 'package:transpeach/app/ui/components/language_dropdown.dart';
import 'package:transpeach/app/ui/components/message_card.dart';

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
                'TranSpeech',
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
              child: Obx(() => Column(
                    children: [
                      for (var message in controller.messages)
                        MessageCard(message: message)
                    ],
                  )),
            ),

            //Inputas Sheet
            Positioned(
              bottom: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: Container(
                  height: 180,
                  width: Get.width,
                  decoration: const BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Traduzir para:',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        LanguageDropdown(
                          onChanged: controller.selectLanguage,
                          value: controller.selectedLanguage,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Digite sua mensagem',
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  fillColor: backgroundColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                controller: controller.textMessageController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Obx(
                                  () => controller.messageText.value.isNotEmpty
                                      ? IconButton(
                                          //função de mandar msg
                                          onPressed: () {
                                            Message newMessage = Message(
                                                text: controller
                                                    .textMessageController.text,
                                                sendAt: DateTime.now());
                                            controller.saveMessage(newMessage);
                                          },
                                          icon: const Icon(
                                            Icons.send,
                                            color: Colors.white,
                                          ),
                                        )
                                      : TextButton(
                                          //função de mandar msg
                                          onPressed: () {
                                            if (controller.isRecording.value) {
                                              // stop recording
                                              controller.stopRecord();
                                              // controller.speechToText(
                                              //     controller.filePath);
                                            } else {
                                              controller.startRecord();
                                            }
                                          },
                                          child: Icon(
                                            controller.isRecording.value
                                                ? Icons.cancel
                                                : Icons.mic,
                                            color: Colors.white,
                                          ),
                                        )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
