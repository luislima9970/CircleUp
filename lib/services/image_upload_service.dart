import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Abre a câmara para tirar uma foto
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
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
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
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
    try {
      final fileName =
          'submissions/$groupId/$taskId/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final uploadTask = _storage.ref(fileName).putFile(imageFile);

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload: $e');
      return null;
    }
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
