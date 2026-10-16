import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Get.offNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // Large soft pale-sage organic blob, top-right
              Positioned(
                top: -h * 0.12,
                right: -w * 0.28,
                child: CustomPaint(
                  size: Size(w * 0.85, w * 0.85),
                  painter: _BlobPainter(color: t.lightSage),
                ),
              ),
              // Soft beige organic blob, bottom-left
              Positioned(
                bottom: -h * 0.14,
                left: -w * 0.30,
                child: CustomPaint(
                  size: Size(w * 0.9, w * 0.9),
                  painter: _BlobPainter(color: t.beige),
                ),
              ),
              // Small pale sage blob near middle-left
              Positioned(
                top: h * 0.18,
                left: -w * 0.16,
                child: CustomPaint(
                  size: Size(w * 0.38, w * 0.38),
                  painter: _BlobPainter(
                      color: t.lightSage.withValues(alpha: 0.55)),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/illustrations/splash_basket.png',
                              width: w * 0.62,
                              height: w * 0.62,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Shopping List',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: t.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Remember. Add. Buy. Done.',
                              style: TextStyle(
                                fontSize: 15,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Page indicator dots
                  Padding(
                    padding: EdgeInsets.only(bottom: h * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: active ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? t.primary
                                  : t.sage.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;

  _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final s = size.shortestSide;
    path.moveTo(s * 0.52, s * 0.04);
    path.cubicTo(s * 0.82, s * 0.02, s * 0.98, s * 0.24, s * 0.96, s * 0.52);
    path.cubicTo(s * 0.94, s * 0.80, s * 0.74, s * 0.98, s * 0.46, s * 0.96);
    path.cubicTo(s * 0.18, s * 0.94, s * 0.02, s * 0.72, s * 0.05, s * 0.44);
    path.cubicTo(s * 0.08, s * 0.18, s * 0.24, s * 0.06, s * 0.52, s * 0.04);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.color != color;
}
