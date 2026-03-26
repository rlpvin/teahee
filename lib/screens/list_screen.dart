import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../models/teacup.dart';
import '../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/media_preview.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final StorageService _storageService = StorageService();
  List<TeaCup> _teaCups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeaCups();
  }

  Future<void> _loadTeaCups() async {
    setState(() => _isLoading = true);
    final cups = await _storageService.getAllTeaCups();
    setState(() {
      _teaCups = cups;
      _isLoading = false;
    });
  }

  Future<void> _exportBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Manage External Storage permission is required for backup.")),
            );
          }
          return;
        }
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      try {
        await _storageService.exportData(selectedDirectory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.deepGreen,
              content: Text("Backup exported to $selectedDirectory/TeaHee_Backup", style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.dangerRed,
              content: Text("Export failed: $e", style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      }
    }
  }

  Future<void> _importBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Manage External Storage permission is required for import.")),
            );
          }
          return;
        }
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      try {
        await _storageService.importData(selectedDirectory);
        await _loadTeaCups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.deepGreen,
              content: Text("Backup imported successfully!", style: TextStyle(color: Colors.white)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.dangerRed,
              content: Text("Import failed: $e", style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      }
    }
  }

  Widget item(TeaCup teacup, BuildContext context) {
    Widget leading;
    if (teacup.mediaPaths.isNotEmpty) {
      leading = Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.black12,
        ),
        clipBehavior: Clip.antiAlias,
        child: MediaThumbnail(path: teacup.mediaPaths.first),
      );
    } else {
      IconData iconData;
      switch (teacup.type) {
        case "Tall":
          iconData = Icons.short_text;
          break;
        case "Grande":
          iconData = Icons.image;
          break;
        case "Venti":
          iconData = Icons.layers;
          break;
        default:
          iconData = Icons.local_cafe;
      }
      leading = CircleAvatar(
        backgroundColor: Colors.white10,
        child: Icon(iconData, color: AppColors.accentGreen),
      );
    }

    return ListTile(
      leading: leading,
      title: Text(teacup.title),
      subtitle: Row(
        children: [
          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(teacup.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: Text(
        teacup.type,
        style: const TextStyle(fontSize: 12, color: AppColors.accentGreen, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(teacup: teacup)),
        );
        _loadTeaCups();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TeaKettle"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportBackup();
              } else if (value == 'import') {
                _importBackup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text("Export Backup"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text("Import Backup"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teaCups.isEmpty
              ? const Center(child: Text("No TeaCups yet. Pour one!"))
              : ListView.builder(
                  itemCount: _teaCups.length,
                  itemBuilder: (context, index) {
                    return item(_teaCups[index], context);
                  },
                ),
    );
  }
}
