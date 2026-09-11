import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
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
  bool isSaving = false;
  Plant? plant;
  final DatabaseService dbService = DatabaseService.instance;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadPlant();
  }

  Future<void> loadPlant() async {
    final loadedPlant = await dbService.readPlant(widget.plantId);
    if (mounted) {
      setState(() => plant = loadedPlant);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  void resetImage() {
    setState(() => image = null);
  }

  Future<void> saveImage() async {
    if (image == null) return;

    setState(() => isSaving = true);

    final directory = await path_provider.getApplicationDocumentsDirectory();
    final imgDir = Directory('${directory.path}/plant_images');
    if (!await imgDir.exists()) await imgDir.create();

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
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

    setState(() {
      isSaving = false;
      image = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo saved")),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;

  return Scaffold(
    appBar: AppBar(title: const Text("Take a Picture")),
    body: SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                plant != null ? plant!.name : "Loading...",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                "Photo for this plant",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withAlpha(140),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 300,
                    width: 300,
                    color: scheme.surfaceContainerLow,
                    child: image != null
                        ? Image.file(image!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              "No Image Selected",
                              style: TextStyle(
                                color: scheme.onSurface.withAlpha(140),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isSaving) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text("Saving photo..."),
              ] else if (image == null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Take Photo"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Choose from Gallery"),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: resetImage,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retake / Repick"),
                        ),
                        ElevatedButton.icon(
                          onPressed: saveImage,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Image"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}