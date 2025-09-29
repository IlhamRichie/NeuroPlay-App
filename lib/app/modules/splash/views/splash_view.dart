import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Baris ini penting untuk memanggil onReady() di controller
    Get.find<SplashController>(); 
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}