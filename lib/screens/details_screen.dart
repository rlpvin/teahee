import 'package:flutter/material.dart';
import 'edit/edit_tall_screen.dart';
import 'edit/edit_grande_screen.dart';
import 'edit/edit_venti_screen.dart';
import '../theme/app_theme.dart';

class DetailsScreen extends StatelessWidget {
  final String type;

  const DetailsScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TeaCup Details")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Beach Day", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              const Text("April 20, 2024"),
              const SizedBox(height: 16),

              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: const Center(child: Text("Photo")),
              ),

              const SizedBox(height: 16),

              const Text(
                "Spent the day at the beach, enjoyed the sun and waves...",
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Widget editScreen = const EditTallScreen();
                        if (type == "Grande") {
                          editScreen = const EditGrandeScreen();
                        } else if (type == "Venti") {
                          editScreen = const EditVentiScreen();
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => editScreen,
                          ),
                        );
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: AppButtons.dangerButton,
                      onPressed: () {},
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
