import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tablebooking/Screens/tablebooking.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    _navigateAfterSplash();
  }

  @override
  void onReady() async {
    super.onReady();
    _navigateAfterSplash();
  }

  void _navigateAfterSplash() {
    Timer(const Duration(seconds: 5), () {
      Get.offAll(() => TableListScreennew());

      update();
    });
  }
}
