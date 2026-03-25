import 'package:flutter/material.dart';
import 'edit/edit_tall_screen.dart';
import 'edit/edit_grande_screen.dart';
import 'edit/edit_venti_screen.dart';
import '../theme/app_theme.dart';
import '../models/teacup.dart';
import '../services/storage_service.dart';
import 'dart:io';

class DetailsScreen extends StatelessWidget {
  final TeaCup teacup;
  final StorageService _storageService = StorageService();

  DetailsScreen({super.key, required this.teacup});

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
              Text(teacup.title, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(teacup.date),
              const SizedBox(height: 16),

              if (teacup.mediaPaths.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: Image.file(
                    File(teacup.mediaPaths.first),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text("Media")),
                  ),
                ),

              if (teacup.mediaPaths.isNotEmpty) const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(teacup.content),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Widget editScreen = EditTallScreen(teacup: teacup);
                        if (teacup.type == "Grande") {
                          editScreen = EditGrandeScreen(teacup: teacup);
                        } else if (teacup.type == "Venti") {
                          editScreen = EditVentiScreen(teacup: teacup);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => editScreen,
                          ),
                        ).then((_) {
                           Navigator.pop(context);
                        });
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: AppButtons.dangerButton,
                      onPressed: () async {
                         await _storageService.deleteTeaCup(teacup.id);
                         if (context.mounted) {
                           Navigator.pop(context);
                         }
                      },
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
