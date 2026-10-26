import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_info.dart';
import '../../theme/app_theme.dart';

/// What the app is, and which build is installed.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'About',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          child: Column(
            children: [
              Image.asset(
                'assets/illustrations/splash_basket.png',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                AppInfo.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: t.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppInfo.tagline,
                style: TextStyle(fontSize: 13.5, color: t.textSecondary),
              ),
              const SizedBox(height: 18),
              Text(
                AppInfo.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: t.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: t.lightSage,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppInfo.versionLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
