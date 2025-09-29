import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Cek status auth setelah halaman siap
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Get.offAllNamed(Routes.LOGIN); // Belum login -> ke halaman Login
      } else {
        Get.offAllNamed(Routes.HOME); // Sudah login -> ke halaman Home
      }
    });
  }
}