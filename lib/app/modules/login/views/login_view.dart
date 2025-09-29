import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahkan logo atau nama aplikasi Anda di sini
            const Text(
              "NeuroPlay",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              } else {
                return ElevatedButton.icon(
                  icon: Image.asset('assets/google.png', height: 24.0), // Pastikan Anda punya logo Google di assets
                  label: const Text('Masuk dengan Google'),
                  onPressed: () {
                    controller.signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}