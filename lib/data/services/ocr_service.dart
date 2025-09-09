
        import 'dart:io';
        import 'package:flutter/material.dart';
        import 'package:image_picker/image_picker.dart';
        import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
        import 'package:flutter/services.dart';
class OCRApp extends StatefulWidget {
  const OCRApp({super.key});

          @override
          _OCRAppState createState() => _OCRAppState();
        }
        
        class _OCRAppState extends State {
          File? _image;
          String extractedText = "";
        
          Future _pickImage(ImageSource source) async {
          final pickedFile = await ImagePicker().pickImage(source: source);
          if (pickedFile != null) {
            setState(() {
              _image = File(pickedFile.path);
              extractedText = "";
            });
          }
          }
        
          Future _extractTextMLKit() async {
          if (_image == null) return;
          final inputImage = InputImage.fromFile(_image!);
          final textRecognizer = TextRecognizer();
          final RecognizedText recognizedText =
              await textRecognizer.processImage(inputImage);
          setState(() {
            extractedText = recognizedText.text;
          });
          print(extractedText);
          textRecognizer.close();
          }
        
        
          Widget _displayExtractedText() {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText(
                    extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: extractedText));
                    },
                    child: const Text("Copy"),
                  ),
                ],
              ),
            ],
          );
          }
        
          @override
          Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Flutter OCR App")),
            body: Column(
              children: [
                if (_image != null) Image.file(_image!, height: 200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text("Capture Image"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text("Select from Gallery"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _extractTextMLKit,
                      child: const Text("Extract Content"),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Expanded(child: _displayExtractedText()),
              ],
            ),
          );
          }
        }
      