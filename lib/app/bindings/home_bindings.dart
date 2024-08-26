import 'package:get/instance_manager.dart';
import 'package:transpeach/app/controllers/home_controller.dart';

class HomeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}