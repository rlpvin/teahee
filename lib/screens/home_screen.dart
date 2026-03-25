import 'package:flutter/material.dart';
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
              child: Text("Pour a TeaCup", style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.center,
              child: Text("Choose a Recipe:"),
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
          ],
        ),
      ),
    );
  }
}
