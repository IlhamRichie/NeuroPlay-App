// lib/main.dart

import 'package:firebase_core/firebase_core.dart'; // <-- Import Firebase
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart'; // <-- Import file konfigurasi Firebase

Future<void> main() async {
  // Pastikan semua binding Flutter siap sebelum menjalankan kode native
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NeuroPlay",
      initialRoute: AppPages.INITIAL, // Ini akan mengarah ke SPLASH
      getPages: AppPages.routes,
    ),
  );
}