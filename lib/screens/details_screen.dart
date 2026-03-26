import 'package:flutter/material.dart';
import 'edit_screen.dart';
import '../theme/app_theme.dart';
import '../models/teacup.dart';
import '../services/storage_service.dart';
import '../widgets/media_preview.dart';

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(teacup.formattedTitle, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(teacup.date, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),

              if (teacup.mediaPaths.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: MediaPreviewList(mediaPaths: teacup.mediaPaths),
                ),

              if (teacup.mediaPaths.isNotEmpty) const SizedBox(height: 16),

              Text(teacup.formattedContent),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Widget editScreen = EditScreen(teacup: teacup);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => editScreen,
                          ),
                        ).then((_) {
                           if (context.mounted) {
                             Navigator.pop(context);
                           }
                        });
                      },
                      label: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: AppButtons.dangerButton,
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete TeaCup?"),
                            content: const Text(
                                "Are you sure you want to pour this TeaCup away? This cannot be undone."),
                            actions: [
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: AppButtons.dangerButton,
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
 
                        if (confirmed == true) {
                          await _storageService.deleteTeaCup(teacup.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      label: const Text("Delete"),
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
