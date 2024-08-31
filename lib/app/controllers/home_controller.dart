import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {

  final textMessageController = TextEditingController();


  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;

  void selectLanguage(String? value) {
    _selectedLanguage = value;
    update();
  }
}