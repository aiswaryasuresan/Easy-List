import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/app_info.dart';
import 'app/modules/settings/settings_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(SettingsController());
  runApp(const ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Obx(
      () => GetMaterialApp(
        title: AppInfo.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
      ),
    );
  }
}
