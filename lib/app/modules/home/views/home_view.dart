// lib/app/modules/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroPlay'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon atau gambar
              Icon(
                Icons.self_improvement, // Menggambarkan rehabilitasi/latihan
                size: 120,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),

              // Teks Sambutan
              Text(
                'Selamat Datang, ${controller.patientName}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Teks Deskripsi
              const Text(
                'Siap untuk memulai sesi rehabilitasi Anda hari ini?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Tombol Aksi
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                // Menggunakan routing dari GetX
                onPressed: () {
                  Get.toNamed(Routes.EXERCISE);
                },
                child: const Text('Mulai Latihan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}