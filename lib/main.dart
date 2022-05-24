import 'package:aichat/app/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/controllers/auth_controller.dart';
import 'app/utils/splash_screen.dart';
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final authC = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Obx(
            () => GetMaterialApp(
              defaultTransition: Transition.fade,
              debugShowCheckedModeBanner: false,
              translations: AppTranslation(),
              locale: Get.deviceLocale,
              title: "AI CHAT",
              theme: ThemeData(
                scaffoldBackgroundColor: Color(0XFFF7F7F7),
                fontFamily: "Nunito",
                brightness: Brightness.light,
                primaryColor: Colors.white,
              ),
              initialRoute: authC.isAuth.isTrue ? Routes.HOME : Routes.LOGIN,
              getPages: AppPages.routes,
            ),
          );
        }
        return FutureBuilder(
          future: authC.firstInitialized(),
          builder: (context, snapshot) => SplashScreen(),
        );
      },
    );
  }
}
