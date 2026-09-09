import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:gallery_saver_plus/gallery_saver.dart';

class CameraPage extends StatefulWidget {
  final int plantId;
  const CameraPage({super.key, required this.plantId});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? image;
  final DatabaseService dbService = DatabaseService.instance;
  final picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📸 Take a Picture")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 300,
                width: 300,
                color: Colors.white,
                child: image != null
                    ? Image.file(image!, fit: BoxFit.cover)
                    : const Center(
                        child: Text("No Image Selected 🌱",
                            style: TextStyle(color: Colors.grey)),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (image == null) return;
                    final directory =
                        await path_provider.getApplicationDocumentsDirectory();
                    final imgDir = Directory('${directory.path}/plant_images');
                    if (!await imgDir.exists()) await imgDir.create();

                    final fileName =
                        '${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final savedImage =
                        await File(image!.path).copy('${imgDir.path}/$fileName');

                    await dbService.createPhoto(
                      Photo(
                        plantId: widget.plantId,
                        imagePath: savedImage.path,
                        takenAt: DateTime.now(),
                      ),
                    );
                    await GallerySaver.saveImage(savedImage.path);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Photo saved! 🌿")),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Image"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}