import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:teahee/models/teacup.dart';
import 'package:teahee/services/storage_service.dart';

void main() {
  late StorageService storageService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('teahee_test');
    storageService = StorageService(testDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('StorageService Tests', () {
    test('saveTeaCup creates a JSON file', () async {
      final teacup = TeaCup(
        id: 'test_id',
        title: 'Test',
        content: 'Content',
        date: '2026-03-27',
        type: 'Tall',
      );

      await storageService.saveTeaCup(teacup);

      final file = File('${tempDir.path}/TeaCups/test_id.json');
      expect(await file.exists(), isTrue);

      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      expect(json['id'], 'test_id');
      expect(json['title'], 'Test');
    });

    test('getAllTeaCups retrieves saved TeaCups', () async {
      final cup1 = TeaCup(id: '1', title: 'A', content: 'C', date: 'D', type: 'Tall');
      final cup2 = TeaCup(id: '2', title: 'B', content: 'C', date: 'D', type: 'Tall');

      await storageService.saveTeaCup(cup1);
      await storageService.saveTeaCup(cup2);

      final cups = await storageService.getAllTeaCups();

      expect(cups.length, 2);
      // StorageService sorts by ID descending
      expect(cups[0].id, '2');
      expect(cups[1].id, '1');
    });

    test('saveTeaCup updates an existing TeaCup (text and media)', () async {
      final cup = TeaCup(id: 'update_me', title: 'Old', content: 'C', date: 'D', type: 'Tall');
      await storageService.saveTeaCup(cup);

      // Create a dummy media file to add
      final dummyMedia = File('${tempDir.path}/new_media.jpg');
      await dummyMedia.writeAsString('data');

      final updatedCup = TeaCup(
        id: 'update_me', 
        title: 'New', 
        content: 'New Content', 
        date: 'D', 
        type: 'Grande',
        mediaPaths: [dummyMedia.path],
      );
      await storageService.saveTeaCup(updatedCup);

      final cups = await storageService.getAllTeaCups();
      expect(cups.length, 1);
      expect(cups[0].title, 'New');
      expect(cups[0].content, 'New Content');
      expect(cups[0].type, 'Grande');
      expect(cups[0].mediaPaths.length, 1);
      expect(File(cups[0].mediaPaths[0]).existsSync(), isTrue);

      // Now remove the media
      final noMediaCup = TeaCup(id: 'update_me', title: 'New', content: 'New Content', date: 'D', type: 'Tall', mediaPaths: []);
      await storageService.saveTeaCup(noMediaCup);

      final finalCups = await storageService.getAllTeaCups();
      expect(finalCups[0].mediaPaths.isEmpty, isTrue);
    });

    test('deleteTeaCup removes the JSON file', () async {
      final cup = TeaCup(id: 'delete_me', title: 'T', content: 'C', date: 'D', type: 'Tall');
      await storageService.saveTeaCup(cup);

      final file = File('${tempDir.path}/TeaCups/delete_me.json');
      expect(await file.exists(), isTrue);

      await storageService.deleteTeaCup('delete_me');
      expect(await file.exists(), isFalse);
    });

    test('deleteTeaCup also deletes associated media', () async {
      // Create a dummy media file
      final mediaPath = '${tempDir.path}/dummy_media.png';
      final mediaFile = File(mediaPath);
      await mediaFile.writeAsString('fake image data');

      final cup = TeaCup(
        id: 'media_cup',
        title: 'T',
        content: 'C',
        date: 'D',
        type: 'Tall',
        mediaPaths: [mediaPath],
      );

      // saveTeaCup will copy the media to the internal media folder
      await storageService.saveTeaCup(cup);
      
      final cups = await storageService.getAllTeaCups();
      final internalMediaPath = cups[0].mediaPaths[0];
      expect(File(internalMediaPath).existsSync(), isTrue);

      // Delete the cup
      await storageService.deleteTeaCup('media_cup');
      
      // JSON file should be gone
      expect(File('${tempDir.path}/TeaCups/media_cup.json').existsSync(), isFalse);
      
      // Internal media file should be gone
      expect(File(internalMediaPath).existsSync(), isFalse);
    });
  });
}
