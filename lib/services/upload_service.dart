// lib/services/upload_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// API base:
/// - Android emulator: http://10.0.2.2:8000
/// - iOS simulator / desktop: http://127.0.0.1:8000
/// - Real device: use your PC's LAN IP, e.g. http://192.168.1.50:8000
const String kApiBase = "http://127.0.0.1:8000";

/// Upload a PDF/Image picked from storage.
Future<void> uploadFromFile(BuildContext context) async {
  try {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'tiff', 'pdf'],
      withData: false,
    );
    if (picked == null || picked.files.single.path == null) return;

    final path = picked.files.single.path!;
    final uri = Uri.parse('$kApiBase/upload');

    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', path));

    final resp = await req.send();

    if (!context.mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Successfully uploaded & processed')),
      );
    } else {
      final body = await resp.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed (${resp.statusCode}) $body')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e')),
    );
  }
}

/// Capture from camera then upload.
Future<void> captureAndUpload(BuildContext context) async {
  final picker = ImagePicker();
  try {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return; // user cancelled

    final file = File(picked.path);
    final uri = Uri.parse('$kApiBase/upload');

    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await req.send();

    if (!context.mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 Successfully captured & processed')),
      );
    } else {
      final body = await resp.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed (${resp.statusCode}) $body')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e')),
    );
  }
}
