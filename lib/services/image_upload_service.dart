import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;

  ImageUploadService({FirebaseStorage? storage, ImagePicker? imagePicker,})  : 
  _storage = storage ?? FirebaseStorage.instance,
        _imagePicker = imagePicker ?? ImagePicker();

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        debugPrint('Imagem capturada da câmera: ${file.path}');
        return file;
      }
      debugPrint('Nenhuma imagem capturada da câmera');
      return null;
    } catch (e) {
      debugPrint('Erro ao abrir câmara: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        debugPrint('Imagem selecionada da galeria: ${file.path}');
        return file;
      }
      debugPrint('Nenhuma imagem selecionada da galeria');
      return null;
    } catch (e) {
      debugPrint('Erro ao abrir galeria: $e');
      return null;
    }
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    late final String fileName;
    late final SettableMetadata metadata;

    try {
      if (!await imageFile.exists()) {
        debugPrint('Erro: Arquivo de imagem não existe');
        return null;
      }

      final fileSize = await imageFile.length();
      debugPrint('Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        debugPrint('Erro: Arquivo de imagem está vazio');
        return null;
      }

      if (fileSize > 10 * 1024 * 1024) {
        debugPrint('Erro: Arquivo muito grande ($fileSize bytes)');
        return null;
      }

      fileName =
          'submissions/$groupId/$taskId/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      debugPrint('Fazendo upload para: $fileName');

      metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId},
      );

      final uploadTask = _storage.ref(fileName).putFile(imageFile, metadata);

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          debugPrint('Progresso do upload: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        },
        onError: (error) {
          debugPrint('Upload snapshot error: $error');
        },
      );

      final taskSnapshot = await uploadTask;
      debugPrint('Upload concluído, obtendo URL de download...');

      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint('URL de download obtida: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('Erro detalhado ao fazer upload: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Tipo do erro: ${e.runtimeType}');
      if (e is FirebaseException) {
        debugPrint('Código do erro Firebase: ${e.code}');
        debugPrint('Mensagem do erro Firebase: ${e.message}');
        debugPrint('Plugin do erro Firebase: ${e.plugin}');

        if (e.code == 'object-not-found') {
          final bucket = _storage.bucket;
          debugPrint('Tentando recuperar bucket alternativo para projeto... Bucket atual: $bucket');
          return await _retryWithAlternateBucket(
            fileName: fileName,
            imageFile: imageFile,
            metadata: metadata,
          );
        }
      }
      return null;
    }
  }

  Future<String?> _retryWithAlternateBucket({
    required String fileName,
    required File imageFile,
    required SettableMetadata metadata,
  }) async {
    const candidates = [
      'gs://t3-prototype-circleup.appspot.com',
      't3-prototype-circleup.appspot.com',
      'gs://t3-prototype-circleup.firebasestorage.app',
      't3-prototype-circleup.firebasestorage.app',
    ];

    for (final bucket in candidates) {
      if (bucket == _storage.bucket) continue;
      try {
        debugPrint('Tentando bucket alternativo: $bucket');
        final backupStorage = FirebaseStorage.instanceFor(bucket: bucket);
        final uploadTask = backupStorage.ref(fileName).putFile(imageFile, metadata);

        uploadTask.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            debugPrint('Progresso do upload com bucket alternativo: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
          },
          onError: (error) {
            debugPrint('Upload snapshot error (alternative bucket): $error');
          },
        );

        final taskSnapshot = await uploadTask;
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        debugPrint('Upload alternativo concluído: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        debugPrint('Falha no upload com bucket $bucket: $e');
      }
    }

    return null;
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar imagem: $e');
      return false;
    }
  }
}
