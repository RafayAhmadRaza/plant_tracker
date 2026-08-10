import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

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
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Take a Picture", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: image != null
                  ? Image.file(image!)
                  : Center(child: Text("No Image Selected")),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera),
                  child: Text("Camera"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (image == null) {
                      debugPrint("Take a picture first");
                    } else {
                      final directory = await path_provider
                          .getApplicationDocumentsDirectory();

                      final imgDir = Directory(
                        '${directory.path}/plant_images',
                      );

                      if (!await imgDir.exists()) {
                        await imgDir.create();
                      }

                      final fileName =
                          '${DateTime.now().millisecondsSinceEpoch}.jpg';
                      final savedImage = await File(
                        image!.path,
                      ).copy('${imgDir.path}/$fileName');

                      dbService.createPhoto(
                        Photo(
                          plantId: widget.plantId,
                          imagePath: savedImage.path,
                          takenAt: DateTime.now(),
                        ),
                      );
                    }
                  },
                  child: Text("Save Image"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
