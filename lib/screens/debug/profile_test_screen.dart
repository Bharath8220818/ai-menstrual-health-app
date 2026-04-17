import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/providers/auth_provider.dart';

class ProfileTestScreen extends StatefulWidget {
  const ProfileTestScreen({super.key});

  @override
  State<ProfileTestScreen> createState() => _ProfileTestScreenState();
}

class _ProfileTestScreenState extends State<ProfileTestScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected.')));
        return;
      }
      auth.updateProfile(avatarPath: file.path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${auth.name}'),
            const SizedBox(height: 8),
            Text('Weight: ${auth.weight} kg'),
            const SizedBox(height: 8),
            Text('Height: ${auth.height} cm'),
            const SizedBox(height: 12),
            Center(
              child: auth.avatarPath != null && auth.avatarPath!.isNotEmpty
                  ? CircleAvatar(radius: 48, backgroundImage: FileImage(File(auth.avatarPath!)))
                  : const CircleAvatar(radius: 48, child: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            if (_isPicking) const Center(child: CircularProgressIndicator()),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick From Gallery'),
              onPressed: _isPicking ? null : () => _pick(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: _isPicking ? null : () => _pick(ImageSource.camera),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              child: const Text('Clear Avatar'),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).updateProfile(avatarPath: '');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar cleared')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

