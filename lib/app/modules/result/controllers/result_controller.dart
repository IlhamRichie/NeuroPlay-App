// lib/app/modules/result/result_controller.dart
import 'package:get/get.dart';

class ResultController extends GetxController {
  late int finalScore;

  @override
  void onInit() {
    super.onInit();
    // Ambil data skor yang dikirim dari halaman sebelumnya
    finalScore = Get.arguments ?? 0;
  }
}