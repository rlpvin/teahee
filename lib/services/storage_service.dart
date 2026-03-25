import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/teacup.dart';

class StorageService {
  static const String _folderName = 'TeaCups';
  static const String _mediaFolderName = 'TeaHeeMedia';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_folderName';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<String> get _mediaPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_mediaFolderName';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> saveTeaCup(TeaCup teacup) async {
    List<String> newMediaPaths = [];
    final mediaDir = await _mediaPath;
    
    for (String path in teacup.mediaPaths) {
      if (!path.startsWith(mediaDir)) {
        final File file = File(path);
        if (await file.exists()) {
          final extension = path.contains('.') ? '.${path.split('.').last}' : '';
          final fileName = const Uuid().v4() + extension;
          final newFilePath = '$mediaDir/$fileName';
          await file.copy(newFilePath);
          newMediaPaths.add(newFilePath);
        } else {
          newMediaPaths.add(path);
        }
      } else {
        newMediaPaths.add(path);
      }
    }

    final updatedTeaCup = TeaCup(
      id: teacup.id,
      title: teacup.title,
      content: teacup.content,
      date: teacup.date,
      type: teacup.type,
      mediaPaths: newMediaPaths,
    );

    final folder = await _localPath;
    final file = File('$folder/${updatedTeaCup.id}.json');
    await file.writeAsString(jsonEncode(updatedTeaCup.toJson()));
  }

  Future<List<TeaCup>> getAllTeaCups() async {
    try {
      final folder = await _localPath;
      final dir = Directory(folder);
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<TeaCup> cups = [];
      
      for (var entity in entities) {
        if (entity is File && entity.path.endsWith('.json')) {
          final contents = await entity.readAsString();
          final jsonMap = jsonDecode(contents);
          cups.add(TeaCup.fromJson(jsonMap));
        }
      }
      
      cups.sort((a, b) => b.id.compareTo(a.id)); 
      return cups;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteTeaCup(String id) async {
    final folder = await _localPath;
    final file = File('$folder/$id.json');
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        final jsonMap = jsonDecode(contents);
        final cup = TeaCup.fromJson(jsonMap);
        for (var mediaPath in cup.mediaPaths) {
          final mediaFile = File(mediaPath);
          if (await mediaFile.exists()) {
            await mediaFile.delete();
          }
        }
      } catch (e) {
        // Ignore read errors
      }
      await file.delete();
    }
  }
}
