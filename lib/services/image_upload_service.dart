import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  ImageUploadService() {
    print('ImageUploadService initialized with bucket: ${_storage.bucket}');
  }

  /// Abre a câmara para tirar uma foto
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
        print('Imagem capturada da câmera: ${file.path}');
        return file;
      }
      print('Nenhuma imagem capturada da câmera');
      return null;
    } catch (e) {
      print('Erro ao abrir câmara: $e');
      return null;
    }
  }

  /// Abre a galeria para selecionar uma foto
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
        print('Imagem selecionada da galeria: ${file.path}');
        return file;
      }
      print('Nenhuma imagem selecionada da galeria');
      return null;
    } catch (e) {
      print('Erro ao abrir galeria: $e');
      return null;
    }
  }

  /// Faz upload da imagem para Firebase Storage
  /// Retorna a URL da imagem ou null em caso de erro
  Future<String?> uploadImage({
    required File imageFile,
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    late final String fileName;
    late final SettableMetadata metadata;

    try {
      // Verificar se o arquivo existe e tem tamanho válido
      if (!await imageFile.exists()) {
        print('Erro: Arquivo de imagem não existe');
        return null;
      }

      final fileSize = await imageFile.length();
      print('Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        print('Erro: Arquivo de imagem está vazio');
        return null;
      }

      if (fileSize > 10 * 1024 * 1024) {
        print('Erro: Arquivo muito grande (${fileSize} bytes)');
        return null;
      }

      fileName =
          'submissions/$groupId/$taskId/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      print('Fazendo upload para: $fileName');

      metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId},
      );

      final uploadTask = _storage.ref(fileName).putFile(imageFile, metadata);

      // Monitorar o progresso do upload
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print('Progresso do upload: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        },
        onError: (error) {
          print('Upload snapshot error: $error');
        },
      );

      final taskSnapshot = await uploadTask;
      print('Upload concluído, obtendo URL de download...');

      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('URL de download obtida: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('Erro detalhado ao fazer upload: $e');
      print('Stack trace: $stackTrace');
      print('Tipo do erro: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('Código do erro Firebase: ${e.code}');
        print('Mensagem do erro Firebase: ${e.message}');
        print('Plugin do erro Firebase: ${e.plugin}');

        if (e.code == 'object-not-found') {
          final bucket = _storage.bucket;
          print('Tentando recuperar bucket alternativo para projeto... Bucket atual: $bucket');
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
        print('Tentando bucket alternativo: $bucket');
        final backupStorage = FirebaseStorage.instanceFor(bucket: bucket);
        final uploadTask = backupStorage.ref(fileName).putFile(imageFile, metadata);

        uploadTask.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            print('Progresso do upload com bucket alternativo: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
          },
          onError: (error) {
            print('Upload snapshot error (alternative bucket): $error');
          },
        );

        final taskSnapshot = await uploadTask;
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print('Upload alternativo concluído: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        print('Falha no upload com bucket $bucket: $e');
      }
    }

    return null;
  }

  /// Deleta uma imagem do Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar imagem: $e');
      return false;
    }
  }
}
