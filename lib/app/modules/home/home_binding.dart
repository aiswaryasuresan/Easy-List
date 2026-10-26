import 'package:get/get.dart';

import '../previous_lists/previous_list_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PreviousListController());
  }
}
