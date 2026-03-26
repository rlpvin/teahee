import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../navigation/main_navigation.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 400),
              painter: TeaPourPainter(progress: _controller.value),
            );
          },
        ),
      ),
    );
  }
}

class TeaPourPainter extends CustomPainter {
  final double progress;
  TeaPourPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final teaPaint = Paint()
      ..color = AppColors.accentGreen.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // --- Draw Cup ---
    final cupPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.7)
      ..lineTo(size.width * 0.65, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.85, size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.85, size.width * 0.35, size.height * 0.7)
      ..close();
    
    // Draw cup handle
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.72, 20, 30),
      -math.pi / 2,
      math.pi,
      false,
      paint,
    );

    canvas.drawPath(cupPath, paint);

    // --- Fill Cup (Tea) ---
    double fillProgress = 0.0;
    if (progress > 0.3 && progress < 0.8) {
      fillProgress = (progress - 0.3) / 0.5;
    } else if (progress >= 0.8) {
      fillProgress = 1.0;
    }

    if (fillProgress > 0) {
      final fillHeight = 45 * fillProgress;
      final fillPath = Path()
        ..moveTo(size.width * 0.36, size.height * 0.82)
        ..lineTo(size.width * 0.64, size.height * 0.82)
        ..lineTo(size.width * 0.64, size.height * 0.82 - fillHeight)
        ..lineTo(size.width * 0.36, size.height * 0.82 - fillHeight)
        ..close();
      
      canvas.save();
      canvas.clipPath(cupPath);
      canvas.drawPath(fillPath, teaPaint);
      canvas.restore();
    }

    // --- Draw Kettle ---
    double kettleYOffset = 0.0;
    double kettleTilt = 0.0;
    double kettleOpacity = 1.0;

    if (progress < 0.2) {
      kettleYOffset = (1.0 - (progress / 0.2)) * 50;
      kettleOpacity = progress / 0.2;
    } else if (progress > 0.2 && progress < 0.4) {
      kettleTilt = ((progress - 0.2) / 0.2) * (math.pi / 6);
    } else if (progress > 0.4 && progress < 0.7) {
      kettleTilt = math.pi / 6;
    } else if (progress > 0.7 && progress < 0.9) {
      kettleTilt = (1.0 - (progress - 0.7) / 0.2) * (math.pi / 6);
    } else if (progress > 0.9) {
       kettleOpacity = 1.0 - (progress - 0.9) / 0.1;
    }

    canvas.save();
    canvas.translate(size.width * 0.2, size.height * 0.3 + kettleYOffset);
    canvas.rotate(kettleTilt);

    final kettleBody = Path()
      ..moveTo(-40, 20)
      ..lineTo(40, 20)
      ..quadraticBezierTo(50, 20, 50, 0)
      ..lineTo(50, -30)
      ..quadraticBezierTo(50, -50, 0, -50)
      ..quadraticBezierTo(-50, -50, -50, -30)
      ..lineTo(-50, 0)
      ..quadraticBezierTo(-50, 20, -40, 20)
      ..close();
    
    final kettleSpout = Path()
      ..moveTo(45, -10)
      ..lineTo(70, -30)
      ..lineTo(75, -25)
      ..lineTo(50, 5)
      ..close();

    final kettleHandle = Path()
      ..moveTo(-45, -30)
      ..quadraticBezierTo(-70, -30, -70, 0)
      ..quadraticBezierTo(-70, 30, -45, 30);

    final kPaint = Paint()
      ..color = AppColors.accentGreen.withValues(alpha: kettleOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(kettleBody, kPaint);
    canvas.drawPath(kettleSpout, kPaint);
    canvas.drawPath(kettleHandle, kPaint);
    canvas.restore();

    // --- Tea Stream ---
    if (progress > 0.35 && progress < 0.75) {
      final streamPaint = Paint()
        ..color = AppColors.accentGreen.withValues(alpha: 0.8)
        ..strokeWidth = 2.0;
      
      canvas.drawLine(
        Offset(size.width * 0.43, size.height * 0.32),
        Offset(size.width * 0.5, size.height * 0.75),
        streamPaint,
      );
    }
    
    // --- Steam ---
    if (progress > 0.5) {
      final steamProgress = (progress - 0.5) / 0.5;
      final steamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * (1.0 - steamProgress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 0; i < 3; i++) {
        final xShift = (i - 1) * 15.0;
        final yShift = steamProgress * 40.0;
        final steamPath = Path()
          ..moveTo(size.width * 0.5 + xShift, size.height * 0.7 - yShift)
          ..quadraticBezierTo(
            size.width * 0.5 + xShift + 5, 
            size.height * 0.7 - yShift - 10, 
            size.width * 0.5 + xShift, 
            size.height * 0.7 - yShift - 20
          );
        canvas.drawPath(steamPath, steamPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
