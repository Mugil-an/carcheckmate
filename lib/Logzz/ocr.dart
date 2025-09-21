// main.dart or home.dart
import 'package:flutter/material.dart';
import '../services/upload_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarCheckMate'),
        backgroundColor: Color.fromARGB(0, 18, 11, 82),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => uploadFromFile(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload PDF / Image'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => captureAndUpload(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture from Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
