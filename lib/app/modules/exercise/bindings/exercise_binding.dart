import 'package:get/get.dart';

import '../controllers/exercise_controller.dart';

class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExerciseController>(
      () => ExerciseController(),
    );
  }
}
