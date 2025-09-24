import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/exercise_controller.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExerciseView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ExerciseView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
