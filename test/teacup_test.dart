import 'package:flutter_test/flutter_test.dart';
import 'package:teahee/models/teacup.dart';

void main() {
  group('TeaCup Model Tests', () {
    test('TeaCup creation and property initialization', () {
      final teacup = TeaCup(
        id: '1',
        title: 'Test Title',
        content: 'Test Content',
        date: '2026-03-27',
        type: 'Tall',
        mediaPaths: ['path/1', 'path/2'],
      );

      expect(teacup.id, '1');
      expect(teacup.title, 'Test Title');
      expect(teacup.content, 'Test Content');
      expect(teacup.date, '2026-03-27');
      expect(teacup.type, 'Tall');
      expect(teacup.mediaPaths, ['path/1', 'path/2']);
    });

    test('TeaCup JSON serialization and deserialization', () {
      final original = TeaCup(
        id: '2',
        title: 'JSON Test',
        content: 'JSON Content',
        date: '2026-03-27',
        type: 'Grande',
        mediaPaths: ['media/1'],
      );

      final json = original.toJson();
      final decoded = TeaCup.fromJson(json);

      expect(decoded.id, original.id);
      expect(decoded.title, original.title);
      expect(decoded.content, original.content);
      expect(decoded.date, original.date);
      expect(decoded.type, original.type);
      expect(decoded.mediaPaths, original.mediaPaths);
    });

    test('Smart Typography: em-dash conversion', () {
      final teacup = TeaCup(
        id: '3',
        title: 'Title -- dash',
        content: 'Content -- dash',
        date: '2026-03-27',
        type: 'Tall',
      );

      expect(teacup.formattedTitle, 'Title — dash');
      expect(teacup.formattedContent, 'Content — dash');
    });

    test('Smart Typography: opening and closing quotes', () {
      final teacup = TeaCup(
        id: '4',
        title: '"Quote" test',
        content: 'Wait, "this" is a "test"',
        date: '2026-03-27',
        type: 'Tall',
      );

      // Opening quote at start of string or after space
      // Closing quote elsewhere
      expect(teacup.formattedTitle, '“Quote” test');
      expect(teacup.formattedContent, 'Wait, “this” is a “test”');
    });

    test('Smart Typography: handle empty strings', () {
        final teacup = TeaCup(
            id: '5',
            title: '',
            content: '',
            date: '2026-03-27',
            type: 'Tall',
        );

        expect(teacup.formattedTitle, '');
        expect(teacup.formattedContent, '');
    });
  });
}
