import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/teacup.dart';
import '../../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/media_preview.dart';

class EditScreen extends StatefulWidget {
  final TeaCup? teacup;
  final String? initialType;

  const EditScreen({super.key, this.teacup, this.initialType});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final StorageService _storageService = StorageService();
  List<String> _mediaPaths = [];
  late String _currentType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.teacup?.title ?? "");
    _contentController = TextEditingController(text: widget.teacup?.content ?? "");
    _mediaPaths = widget.teacup?.mediaPaths.toList() ?? [];
    _currentType = widget.teacup?.type ?? widget.initialType ?? "Tall";
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
      type: _currentType,
      mediaPaths: _mediaPaths,
    );

    await _storageService.saveTeaCup(cup);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _copyAndAddMedia(String originalPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/TeaCupsMedia');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      final fileName = originalPath.split('/').last;
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final newFile = await File(originalPath).copy('${mediaDir.path}/$uniqueName');
      setState(() {
        _mediaPaths.add(newFile.path);
      });
    } catch (e) {
      debugPrint("Error copying media $e");
      setState(() {
        _mediaPaths.add(originalPath);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _copyAndAddMedia(image.path);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      await _copyAndAddMedia(video.path);
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      await _copyAndAddMedia(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacup == null ? "New $_currentType" : "Edit $_currentType")),
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
              if (_currentType != "Tall" && _mediaPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Text("${_mediaPaths.length} media item(s)", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mediaPaths.length,
                          itemBuilder: (context, index) {
                            final path = _mediaPaths[index];
                            
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black12,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: MediaThumbnail(path: path),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _mediaPaths.remove(path);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (_currentType == "Grande")
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Add Image"),
                ),
              if (_currentType == "Venti")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Image"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickAudio,
                      icon: const Icon(Icons.mic),
                      label: const Text("Audio"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text("Video"),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
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
