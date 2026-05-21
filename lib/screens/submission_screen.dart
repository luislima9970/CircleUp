import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/services/image_upload_service.dart';
import 'package:projesof/services/submission_service.dart';

import '../app_state.dart';
import '../models/task_model.dart';

class SubmissionScreen extends StatefulWidget {
  final String groupId;
  final TaskModel task;
  final String themeColor;

  const SubmissionScreen({
    super.key,
    required this.groupId,
    required this.task,
    this.themeColor = 'Sustainability',
  });

  @override
  State<SubmissionScreen> createState() =>
      _SubmissionScreenState();
}

class _SubmissionScreenState
    extends State<SubmissionScreen> {
  ImageUploadService? _imageUploadService;
  final SubmissionService _submissionService = SubmissionService();

  late final TaskModel _task = widget.task;
  final user = AppState.currentUser!;

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  late Future<bool> _hasSubmittedFuture;

  @override
  void initState() {
    super.initState();
    try {
      _imageUploadService = ImageUploadService();
    } catch (_) {}
    _hasSubmittedFuture = _checkIfUserHasSubmitted();
  }

  Future<bool> _checkIfUserHasSubmitted() async {
    try {
      return await _submissionService.hasUserSubmittedForTask(
        groupId: widget.groupId,
        taskId: _task.id!,
        authorId: user.id!,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getThemeColor() {
    switch (widget.themeColor) {
      case 'Fitness':
        return const Color(0xFF2A8CFF);
      case 'Wellness':
        return const Color(0xFFFFB84D);
      case 'Sustainability':
      default:
        return const Color(0xFF43D17A);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _imageUploadService?.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _imageUploadService?.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _errorMessage = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitProof() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage =
            'Please attach a photo or screenshot before submitting.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageUrl = await _imageUploadService?.uploadImage(
        imageFile: _selectedImage!,
        groupId: widget.groupId,
        taskId: _task.id!,
        userId: user.id!,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image. Please check your internet connection and try again.');
      }

      // Create submission
      await _submissionService.createSubmission(
        groupId: widget.groupId,
        taskId: _task.id!,
        submission: SubmissionModel(userId: user.id!, photoUrl: imageUrl),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim submitted successfully!'),
            backgroundColor: Color(0xFF43D17A),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error submitting claim: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF3),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4FF), Color(0xFFF8FCFF), Color(0xFFEFFAF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                top: -90,
                right: -70,
                child: _BackgroundCircle(
                  size: 210,
                  color: Color.fromARGB(51, 42, 140, 255),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _BackgroundCircle(
                  size: 230,
                  color: Color.fromARGB(51, 67, 209, 122),
                ),
              ),
              // Main content
              FutureBuilder<bool>(
                future: _hasSubmittedFuture,
                builder: (context, snapshot) {
                  final hasSubmitted = snapshot.data ?? false;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF1C2A33),
                                  size: 20,
                                ),
                              ),
                            ),
                            Text(
                              'Submit Proof',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C2A33),
                              ),
                            ),
                            const SizedBox(width: 44),
                          ],
                        ),
                        const SizedBox(height: 28),
                        if (hasSubmitted)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF5E3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF43D17A).withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: const Color(0xFF43D17A),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Proof Already Submitted',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2F7F3F),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'You have already submitted proof for this task. Only one submission per task is allowed.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2F7F3F),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // Info banner
                          Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _getThemeColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getThemeColor().withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getThemeColor(),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Submit your proof',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upload a valid photo or screenshot to complete your challenge claim.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF7A8A94),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Challenge Information Section
                    Text(
                      'Challenge Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Challenge title
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getThemeColor().withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getThemeIcon(),
                                  color: _getThemeColor(),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Challenge',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF95A39A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C2A33),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: const Color(0xFFE8EFF1), height: 1),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            'Description',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF95A39A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _task.objective,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1C2A33),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Attach Proof Section
                    Text(
                      'Attach Proof',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image preview or upload area
                    if (_selectedImage == null)
                      GestureDetector(
                        onTap: () => _showImageSourceDialog(context),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE8EFF1),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _getThemeColor().withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: _getThemeColor(),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No proof attached',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2A33),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload a photo or screenshot',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF95A39A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 280,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: _removeImage,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showImageSourceDialog(context),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F8FB),
                                border: Border.all(
                                  color: const Color(0xFFE8EFF1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      color: _getThemeColor(),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Change Proof',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getThemeColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFFF6B6B,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFD63031),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFD63031),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitProof,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getThemeColor(),
                          disabledBackgroundColor: _getThemeColor().withValues(
                            alpha: 0.5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Claim',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C2A33),
                  ),
                ),
              ),
              Divider(color: const Color(0xFFE8EFF1), height: 1),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: _getThemeColor(),
                  size: 28,
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C2A33),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.image_outlined,
                  color: _getThemeColor(),
                  size: 28,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C2A33),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon() {
    switch (widget.themeColor) {
      case 'Fitness':
        return Icons.fitness_center_rounded;
      case 'Wellness':
        return Icons.self_improvement_rounded;
      case 'Sustainability':
      default:
        return Icons.eco_rounded;
    }
  }
}

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
