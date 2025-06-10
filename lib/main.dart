import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Controller/orderController.dart';
import 'Screens/splash_screen/splash_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(OrderItemAdapter());

  await Hive.openBox<List>('orders');
  await Hive.openBox<String>('occupied_times'); // ✅ Must be Box<String>
  Get.put(OrderController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(title: 'WaiterApp', home: SplashScreen());
  }
}
