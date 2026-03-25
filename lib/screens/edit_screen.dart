import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final FocusNode _contentFocus = FocusNode();
  late String _initialTitle;
  late String _initialContent;
  late List<String> _initialMedia;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.teacup?.title ?? "";
    _initialContent = widget.teacup?.content ?? "";
    _initialMedia = widget.teacup?.mediaPaths.toList() ?? [];
    
    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _mediaPaths = List<String>.from(_initialMedia);
    _currentType = widget.teacup?.type ?? widget.initialType ?? "Tall";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    final titleChanged = _titleController.text != _initialTitle;
    final contentChanged = _contentController.text != _initialContent;
    final mediaChanged = _mediaPaths.length != _initialMedia.length ||
        !_mediaPaths.every((path) => _initialMedia.contains(path));
    return titleChanged || contentChanged || mediaChanged;
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Changes?"),
        content: const Text("You have unsaved changes. Are you sure you want to discard them?"),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep Editing"),
          ),
          ElevatedButton(
            style: AppButtons.dangerButton,
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Discard"),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

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
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final navigator = Navigator.of(context);
          if (!_hasUnsavedChanges()) {
            if (mounted) navigator.pop();
            return;
          }
          final shouldPop = await _showDiscardDialog();
          if (shouldPop == true && mounted) {
            navigator.pop();
          }
        },
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        autofocus: widget.teacup == null,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        spellCheckConfiguration: const SpellCheckConfiguration(),
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_contentFocus);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a title";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        autofocus: widget.teacup != null,
                        minLines: 8,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        smartDashesType: SmartDashesType.enabled,
                        smartQuotesType: SmartQuotesType.enabled,
                        maxLength: 5000,
                        maxLengthEnforcement: MaxLengthEnforcement.none,
                        decoration: const InputDecoration(
                          hintText: "Write your TeaCup...",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please write some content";
                          }
                          return null;
                        },
                      ),
                      if (_currentType != "Tall" && _mediaPaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_mediaPaths.length} media item(s)",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _mediaPaths.length,
                                  itemBuilder: (context, index) {
                                    final path = _mediaPaths[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white24),
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.black12,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: MediaThumbnail(path: path),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _mediaPaths.remove(path);
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_currentType == "Grande")
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Add Image"),
                          ),
                        ),
                      if (_currentType == "Venti")
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text("Image"),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickAudio,
                                icon: const Icon(Icons.mic),
                                label: const Text("Audio"),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.videocam),
                                label: const Text("Video"),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: AppButtons.saveButton,
                      onPressed: _save,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Save"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: AppButtons.cancelButton,
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Cancel"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
