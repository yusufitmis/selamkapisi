import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPreacherDialog extends StatefulWidget {
  const AddPreacherDialog({super.key});

  @override
  _AddPreacherDialogState createState() => _AddPreacherDialogState();
}

class _AddPreacherDialogState extends State<AddPreacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isHistorical = true;
  XFile? _pickedImage;
  bool _isUploading = false;

  // Color scheme
  final Color _primaryColor = const Color(0xFF121212); // Black
  final Color _secondaryColor = const Color(0xFFD4AF37); // Gold
  final Color _backgroundColor = const Color(0xFFFAFAFA); // Off-white
  final Color _textColor = const Color(0xFF333333); // Dark gray
  final Color _hintColor = const Color(0xFF888888); // Gray for hints
  final Color _borderColor = const Color(0xFFE0E0E0); // Light gray

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() => _pickedImage = pickedImage);
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    setState(() => _isUploading = true);
    try {
      final ref = _storage.ref().child('preachers/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(_pickedImage!.path));
      return await ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resim yüklenirken hata oluştu'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Yeni Vaiz Ekle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _secondaryColor,
                      width: 2,
                    ),
                    color: _pickedImage == null ? _secondaryColor.withAlpha((255 * 0.1).round()) : null,
                  ),
                  child: _pickedImage != null
                      ? ClipOval(
                    child: Image.file(
                      File(_pickedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 36,
                        color: _secondaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Resim Ekle',
                        style: TextStyle(
                          color: _secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _pickedImage!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _hintColor,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Vaiz Adı',
                        labelStyle: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                        hintText: 'Vaizin adını yazınız',
                        hintStyle: TextStyle(
                          color: _hintColor,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _secondaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Bu alan zorunludur' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        labelStyle: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                        hintText: 'Vaiz hakkında açıklama yazınız',
                        hintStyle: TextStyle(
                          color: _hintColor,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _secondaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Historical Preacher Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _borderColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Tarihi Din Alimi',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isHistorical,
                      onChanged: (value) => setState(() => _isHistorical = value),
                      activeColor: _secondaryColor,
                      activeTrackColor: _secondaryColor.withAlpha((255 * 0.5).round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Loading Indicator
              if (_isUploading) ...[
                LinearProgressIndicator(
                  minHeight: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _primaryColor.withAlpha((255 * 0.1).round()),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final imageUrl = await _uploadImage();

                          if (imageUrl == null && _pickedImage != null) return;

                          await _firestore.collection('preachers').add({
                            'name': _nameController.text,
                            'description': _descriptionController.text,
                            'imageUrl': imageUrl ?? '',
                            'isHistorical': _isHistorical,
                            'createdAt': Timestamp.now(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Vaiz başarıyla eklendi'),
                                backgroundColor: _primaryColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'KAYDET',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}