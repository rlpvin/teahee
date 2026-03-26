import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'edit_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget recipeButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white),
              right: BorderSide(color: Colors.white),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGreen, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20)),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TeaHee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.local_cafe, color: AppColors.accentGreen, size: 28),
                   SizedBox(width: 12),
                   Text("Pour a TeaCup", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.center,
              child: Text("Choose a Recipe:", style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),

            recipeButton(
              icon: Icons.edit,
              title: "Tall",
              subtitle: "Text Only",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditScreen(initialType: "Tall")),
                );
              },
            ),

            recipeButton(
              icon: Icons.image,
              title: "Grande",
              subtitle: "Text + Image",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditScreen(initialType: "Grande")),
                );
              },
            ),

            recipeButton(
              icon: Icons.mic,
              title: "Venti",
              subtitle: "Text + Media",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditScreen(initialType: "Venti")),
                );
              },
            ),
            const Expanded(child: SizedBox()),
            const Center(child: SteamingCup()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SteamingCup extends StatefulWidget {
  const SteamingCup({super.key});

  @override
  State<SteamingCup> createState() => _SteamingCupState();
}

class _SteamingCupState extends State<SteamingCup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 100),
          painter: SteamPainter(progress: _controller.value),
        );
      },
    );
  }
}

class SteamPainter extends CustomPainter {
  final double progress;
  SteamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Cup
    final cupPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.9, size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.3, size.height * 0.7)
      ..close();
    
    canvas.drawPath(cupPath, paint);
    
    // Steam
    for (int i = 0; i < 3; i++) {
      final p = (progress + (i * 0.33)) % 1.0;
      final opacity = math.sin(p * math.pi) * 0.3;
      final steamPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final xBase = size.width * 0.4 + (i * 10);
      final yBase = size.height * 0.7;
      final yOffset = p * 40;
      final xAmoeba = math.sin(p * math.pi * 2) * 5;

      final steamPath = Path()
        ..moveTo(xBase, yBase - yOffset)
        ..quadraticBezierTo(xBase + 5 + xAmoeba, yBase - yOffset - 10, xBase + xAmoeba, yBase - yOffset - 20);
      
      canvas.drawPath(steamPath, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
