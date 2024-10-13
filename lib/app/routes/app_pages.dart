import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:transpeach/app/bindings/home_bindings.dart';
import 'package:transpeach/app/ui/pages/home_page.dart';

part './app_routes.dart';

class AppPages {
  final List<GetPage> pages = [
    GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: HomeBindings())
  ];
}
