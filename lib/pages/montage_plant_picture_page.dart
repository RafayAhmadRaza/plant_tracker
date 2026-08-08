import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> _createGifIsolate(List<String> ImgPaths) async {
  final encoder = img.GifEncoder();

  for (final path in ImgPaths) {
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes)!;
    final resized = img.resize(image, width: 480);
    encoder.addFrame(resized, duration: 10);
  }
  return encoder.finish()!;
}

class MontagePlantPicturePage extends StatefulWidget {
  const MontagePlantPicturePage({super.key});

  @override
  State<MontagePlantPicturePage> createState() =>
      MontagePlantPicturePageState();
}

class MontagePlantPicturePageState extends State<MontagePlantPicturePage> {
  DatabaseService dbService = DatabaseService.instance;
  List<String> imgPathList = [];
  int selectedPlant = 0;
  List<Photo> photos = [];
  List<Plant> plants = [];
  int currentImageIndex = 0;
  bool isTimerRunning = false;
  Timer? t;

  Future<String> saveGifToDocuments(Uint8List gifBytes) async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint(
      '${dir.path}/plant_growth_${DateTime.now().millisecondsSinceEpoch}.gif',
    );
    final file = File(
      '${dir.path}/plant_growth_${DateTime.now().millisecondsSinceEpoch}.gif',
    );
    await file.writeAsBytes(gifBytes);
    return file.path;
  }

  void clear() {
    currentImageIndex = 0;
    photos.clear();
    imgPathList.clear();
    stopSlideshow();

    setState(() {});
  }

  void stopSlideshow() {
    currentImageIndex = 0;
    t?.cancel();
    t = null;
    isTimerRunning = false;
  }

  void loadPlants() async {
    final loadedplants = await dbService.readAllPlants();

    setState(() {
      plants = loadedplants;
      selectedPlant = loadedplants.first.id!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    loadPlants();
  }

  Future<void> load_photos_path(int id) async {
    imgPathList.clear();
    photos.clear();
    photos = await dbService.readPhotosForPlant(id);

    if (photos.isEmpty) {
      return;
    }
    for (Photo photo in photos) {
      setState(() {
        imgPathList.add(photo.imagePath);
      });
    }
    debugPrint("image loaded");
  }

  DropdownMenuItem<int> buildMenuItem(Plant plant) => DropdownMenuItem(
    value: plant.id,
    child: Text(
      plant.name,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Montage Maker", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 5),
            DropdownButton(
              items: plants.map(buildMenuItem).toList(),
              value: selectedPlant,
              onChanged: (value) {
                setState(() {
                  selectedPlant = value!;
                });
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                debugPrint("Button Pressed");

                await load_photos_path(selectedPlant);

                debugPrint("Loading Done");

                if (imgPathList.isEmpty) {
                  return;
                }
                if (isTimerRunning) {
                  return;
                } else {
                  setState(() {
                    isTimerRunning = true;
                  });
                  t = Timer.periodic(Duration(milliseconds: 1000), (timer) {
                    if (currentImageIndex < imgPathList.length) {
                      setState(() {
                        currentImageIndex++;
                      });
                    }

                    if (currentImageIndex == imgPathList.length) {
                      setState(() {
                        currentImageIndex = 0;
                      });
                    }
                    debugPrint(currentImageIndex.toString());
                  });
                }
              },
              child: Text("Generate Montage"),
            ),
            SizedBox(height: 12),
            if (imgPathList.isNotEmpty) ...[
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Image(
                      image: FileImage(File(imgPathList[currentImageIndex])),
                      gaplessPlayback: true,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Text(
                      (photos[currentImageIndex].takenAt.day.toString() +
                          "-" +
                          photos[currentImageIndex].takenAt.month.toString() +
                          "-" +
                          photos[currentImageIndex].takenAt.year.toString()),
                      style: TextStyle(color: Color(0xFFD7CBB2)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      debugPrint("Saving Gif");

                      final gifBytes = await compute(
                        _createGifIsolate,
                        imgPathList,
                      );
                      await saveGifToDocuments(gifBytes);
                      debugPrint("Saved Gif");
                    },
                    child: Text("Save"),
                  ),
                  SizedBox(width: 100),
                  ElevatedButton(
                    onPressed: () {
                      clear();
                    },
                    child: Text("Clear"),
                  ),
                ],
              ),
            ],
            if (imgPathList.isEmpty) ...[Text("Montage will appear here")],
          ],
        ),
      ),
    );
  }
}
