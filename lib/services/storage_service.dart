import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/teacup.dart';

class StorageService {
  static const String _folderName = 'TeaCups';
  static const String _mediaFolderName = 'TeaHeeMedia';

  final Directory? testDirectory;

  StorageService({this.testDirectory});

  Future<String> get _localPath async {
    final directory = testDirectory ?? await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_folderName';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<String> get _mediaPath async {
    final directory = testDirectory ?? await getApplicationDocumentsDirectory();
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

  Future<void> exportData(String destinationPath) async {
    final rootDir = Directory('$destinationPath/TeaHee_Backup');
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    final mediaDir = Directory('${rootDir.path}/Media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    // Export JSONs
    final localFolderPath = await _localPath;
    final localDir = Directory(localFolderPath);
    final entities = await localDir.list().toList();
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        final fileName = entity.path.split('/').last;
        await entity.copy('${rootDir.path}/$fileName');
      }
    }

    // Export Media
    final localMediaFolderPath = await _mediaPath;
    final localMediaDir = Directory(localMediaFolderPath);
    final mediaEntities = await localMediaDir.list().toList();
    for (var entity in mediaEntities) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        await entity.copy('${mediaDir.path}/$fileName');
      }
    }
  }

  Future<void> importData(String sourcePath) async {
    final sourceDir = Directory(sourcePath);
    final mediaSourceDir = Directory('$sourcePath/Media');
    final internalMediaPath = await _mediaPath;
    final internalStorePath = await _localPath;

    final entities = await sourceDir.list().toList();
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        final contents = await entity.readAsString();
        final Map<String, dynamic> jsonMap = jsonDecode(contents);
        final cup = TeaCup.fromJson(jsonMap);

        List<String> newMediaPaths = [];
        for (var oldPath in cup.mediaPaths) {
          final fileName = oldPath.split('/').last;
          final sourceMediaFile = File('${mediaSourceDir.path}/$fileName');
          
          if (await sourceMediaFile.exists()) {
            final destinationFile = File('$internalMediaPath/$fileName');
            if (!await destinationFile.exists()) {
              await sourceMediaFile.copy(destinationFile.path);
            }
            newMediaPaths.add(destinationFile.path);
          } else {
             // Fallback if media missing from backup but path was there
             newMediaPaths.add(oldPath);
          }
        }

        final updatedCup = TeaCup(
          id: cup.id,
          title: cup.title,
          content: cup.content,
          date: cup.date,
          type: cup.type,
          mediaPaths: newMediaPaths,
        );

        final localFile = File('$internalStorePath/${updatedCup.id}.json');
        await localFile.writeAsString(jsonEncode(updatedCup.toJson()));
      }
    }
  }
}
