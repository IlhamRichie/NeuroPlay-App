import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // 1. Memulai alur Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Pengguna membatalkan proses login
        isLoading.value = false;
        return;
      }

      // 2. Mendapatkan detail autentikasi dari permintaan
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Membuat kredensial baru untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Login ke Firebase dengan kredensial Google
      await _auth.signInWithCredential(credential);

      // 5. Jika berhasil, pindah ke halaman utama
      Get.offAllNamed(Routes.HOME);

    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Login Gagal",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}