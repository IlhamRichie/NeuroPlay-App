// lib/app/modules/exercise/exercise_controller.dart

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ExerciseController extends GetxController {
  // RxBool untuk melacak status inisialisasi kamera secara reaktif
  final isCameraInitialized = false.obs;
  // Controller untuk mengelola kamera
  late CameraController cameraController;
  // Deskripsi kamera yang akan digunakan (misal: kamera depan)
  late CameraDescription frontCamera;

  @override
  void onInit() {
    super.onInit();
    // Memulai proses inisialisasi saat controller dibuat
    initializeCamera();
  }

  @override
  void onClose() {
    // Pastikan untuk melepaskan resource kamera saat controller ditutup
    cameraController.dispose();
    super.onClose();
  }

  Future<void> initializeCamera() async {
    // 1. Minta Izin Kamera
    if (await Permission.camera.request().isGranted) {
      // 2. Dapatkan daftar kamera yang tersedia
      final cameras = await availableCameras();
      // 3. Pilih kamera depan
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      // 4. Inisialisasi CameraController
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Resolusi bisa disesuaikan
        enableAudio: false,
      );

      // 5. Mulai kamera dan update status
      await cameraController.initialize();
      isCameraInitialized.value = true;
      
      // Di sinilah nanti kita akan memulai streaming gambar ke model TFLite
      // cameraController.startImageStream((image) {
      //   // process image frame here...
      // });

    } else {
      // Handle jika pengguna tidak memberikan izin
      print("Izin kamera ditolak");
      Get.snackbar("Error", "Izin kamera diperlukan untuk memulai latihan.");
    }
  }
}