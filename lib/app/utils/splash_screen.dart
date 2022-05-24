import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    loadImage();
    super.initState();
  }

  void loadImage() async {
    final svgs = [
      'assets/svg/pencil.svg',
      'assets/svg/welcome.svg',
    ];
    final promises = svgs.map(
      (e) => precachePicture(
          ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, e), null),
    );
    await Future.wait(promises);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: Get.width * 0.75,
            height: Get.width * 0.75,
            child: Lottie.asset("assets/lottie/hello.json"),
          ),
        ),
      ),
    );
  }
}
