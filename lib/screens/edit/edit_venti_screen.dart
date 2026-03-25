import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/teacup.dart';
import '../../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class EditVentiScreen extends StatefulWidget {
  final TeaCup? teacup;
  const EditVentiScreen({super.key, this.teacup});

  @override
  State<EditVentiScreen> createState() => _EditVentiScreenState();
}

class _EditVentiScreenState extends State<EditVentiScreen> {
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
      type: "Venti",
      mediaPaths: _mediaPaths,
    );

    await _storageService.saveTeaCup(cup);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addMockMedia(String type) {
    setState(() {
      _mediaPaths.add('/mock_path/to_${type}_${_mediaPaths.length}.$type');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacup == null ? "New Venti" : "Edit Venti")),
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
                  child: Text("${_mediaPaths.length} media item(s)", style: const TextStyle(color: Colors.grey)),
                ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _addMockMedia('img'),
                    icon: const Icon(Icons.image),
                    label: const Text("Image"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addMockMedia('aud'),
                    icon: const Icon(Icons.mic),
                    label: const Text("Audio"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addMockMedia('vid'),
                    icon: const Icon(Icons.videocam),
                    label: const Text("Video"),
                  ),
                ],
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
