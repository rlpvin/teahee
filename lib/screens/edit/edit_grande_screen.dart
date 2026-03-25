import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/teacup.dart';
import '../../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class EditGrandeScreen extends StatefulWidget {
  final TeaCup? teacup;
  const EditGrandeScreen({super.key, this.teacup});

  @override
  State<EditGrandeScreen> createState() => _EditGrandeScreenState();
}

class _EditGrandeScreenState extends State<EditGrandeScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final StorageService _storageService = StorageService();
  List<String> _mediaPaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.teacup?.title ?? "");
    _contentController = TextEditingController(text: widget.teacup?.content ?? "");
    _mediaPaths = widget.teacup?.mediaPaths.toList() ?? [];
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
      type: "Grande",
      mediaPaths: _mediaPaths,
    );

    await _storageService.saveTeaCup(cup);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addMockMedia() {
    setState(() {
      _mediaPaths.add('/mock_path/to_image_${_mediaPaths.length}.png');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacup == null ? "New Grande" : "Edit Grande")),
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
              if (_mediaPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("${_mediaPaths.length} media item(s) added", style: const TextStyle(color: Colors.grey)),
                ),
              ElevatedButton.icon(
                onPressed: _addMockMedia,
                icon: const Icon(Icons.image),
                label: const Text("Add Image"),
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
