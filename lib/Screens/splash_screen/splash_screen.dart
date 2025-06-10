import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  final splashCtrl = Get.put(SplashController());

  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor:Color(0xffd9e8cb),
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              //  height: double.infinity,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(height: 10.0),
                    Container(width: 150.0, height: 150.0, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/logo.png'), fit: BoxFit.fill))),
                    const SizedBox(height: 10.0),
                    Container(
                      // width: 150.0,
                      height: 150.0,
                      child: Text('Waiter Management System', style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.purple)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
