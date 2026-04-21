// lib/features/splash/view/splash_view.dart

import 'package:aqar_hub/features/splash/logic/splash_navigator.dart';
import 'package:aqar_hub/features/splash/widgets/splash_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Make status bar transparent so gradient fills the whole screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    SplashNavigator.navigate();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // No background color - let SplashContent gradient fill everything
      body: SplashContent(),
    );
  }
}
