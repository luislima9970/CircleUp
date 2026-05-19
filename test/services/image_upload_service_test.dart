import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projesof/services/image_upload_service.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  group('ImageUploadService', () {

    late MockFirebaseStorage mockStorage;
    late ImageUploadService service;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      service = ImageUploadService(storage: mockStorage);
    });

    test('IU1: uploadImage returns null if file does not exist', () async {
      final fakeFile = File('/tmp/nonexistent_file_abc123.jpg');

      final result = await service.uploadImage(
        imageFile: fakeFile,
        groupId: 'g1',
        taskId: 't1',
        userId: 'uid1',
      );

      expect(result, isNull);
    });

    test('IU2: uploadImage returns null if file is empty', () async {
      final tempDir = Directory.systemTemp;
      final emptyFile = File('${tempDir.path}/empty_test_file.jpg');

      await emptyFile.writeAsBytes([]);

      final result = await service.uploadImage(
        imageFile: emptyFile,
        groupId: 'g1',
        taskId: 't1',
        userId: 'uid1',
      );

      expect(result, isNull);

      await emptyFile.delete();
    });

    test('IU3: deleteImage returns false on invalid URL', () async {
      final result = await service.deleteImage(
        'https://invalid-url.com/image.jpg',
      );

      expect(result, false);
    });
  });
}