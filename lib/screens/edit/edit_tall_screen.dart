import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/teacup.dart';
import '../../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class EditTallScreen extends StatefulWidget {
  final TeaCup? teacup;
  const EditTallScreen({super.key, this.teacup});

  @override
  State<EditTallScreen> createState() => _EditTallScreenState();
}

class _EditTallScreenState extends State<EditTallScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.teacup?.title ?? "");
    _contentController = TextEditingController(text: widget.teacup?.content ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final cup = TeaCup(
      id: widget.teacup?.id ?? const Uuid().v4(),
      title: title,
      content: content,
      date: widget.teacup?.date ?? DateTime.now().toLocal().toString().split(' ')[0],
      type: "Tall",
      mediaPaths: widget.teacup?.mediaPaths ?? [],
    );

    await _storageService.saveTeaCup(cup);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacup == null ? "New Tall" : "Edit Tall")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: "Write your TeaCup...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: AppButtons.saveButton,
                    onPressed: _save,
                    child: const Text("Save"),
                  ),
                  OutlinedButton(
                    style: AppButtons.cancelButton,
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
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
