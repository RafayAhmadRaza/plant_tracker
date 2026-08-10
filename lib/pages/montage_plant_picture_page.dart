import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:plant_tracker/Models/colors_storage.dart';

Future<Uint8List> _createGifIsolate(
  (List<(String path, String label)> frames, double duration) data,
) async {
  final encoder = img.GifEncoder();
  final frames = data.$1;
  final duration = data.$2;

  for (final frame in frames) {
    final bytes = await File(frame.$1).readAsBytes();
    final image = img.decodeImage(bytes)!;
    final resized = img.resize(image, width: 720);
    img.drawString(
      resized,
      frame.$2,
      font: img.arial24,
      x: 10,
      y: resized.height - 30,
      color: ColorsStorage.subImageTitleColor,
    );
    encoder.addFrame(resized, duration: (100 * duration).round());
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
  var isSaving = false;
  double montageDuration = 1.0;

  Future<String> saveGifToDocuments(Uint8List gifBytes) async {
    final dir = await getApplicationDocumentsDirectory();

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
    //

    super.initState();

    loadPlants();
  }

  Future<void> loadPhotosPath(int id) async {
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
            // Generate DropDown
            DropdownButton(
              items: plants.map(buildMenuItem).toList(),
              value: selectedPlant,
              onChanged: isSaving
                  ? null
                  : (int? value) {
                      setState(() {
                        selectedPlant = value!;
                      });
                    },
            ),
            // Slider
            SizedBox(height: 12),
            Slider(
              value: montageDuration,
              min: 0.5,
              max: 1.0,
              divisions: 19,
              label: "${montageDuration.toStringAsFixed(1)}s",

              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        montageDuration = value;
                      });
                    },
            ),

            //Generate Montage Button
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      debugPrint("Button Pressed");

                      await loadPhotosPath(selectedPlant);

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
                        t = Timer.periodic(
                          Duration(
                            milliseconds: (1000 * montageDuration).round(),
                          ),
                          (timer) {
                            setState(() {
                              currentImageIndex =
                                  (currentImageIndex + 1) % imgPathList.length;
                            });
                            debugPrint(currentImageIndex.toString());
                          },
                        );
                      }
                    },
              child: Text("Generate Montage"),
            ),
            SizedBox(height: 12),
            if (isSaving == true) ...[
              Text("Saving Gif Please wait!"),
              CircularProgressIndicator(),
            ],
            if (imgPathList.isNotEmpty && isSaving == false) ...[
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
                  Positioned(
                    bottom: -275,
                    left: 40,
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Text(
                        (photos[currentImageIndex].takenAt.day.toString() +
                            "-" +
                            photos[currentImageIndex].takenAt.month.toString() +
                            "-" +
                            photos[currentImageIndex].takenAt.year.toString()),
                        style: TextStyle(color: Color(0xFFD7CBB2)),
                      ),
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
                      setState(() {
                        isSaving = true;
                      });
                      debugPrint("Saving Gif");
                      List<String> datelist = [];
                      for (final photo in photos) {
                        datelist.add(
                          photo.takenAt.day.toString() +
                              "-" +
                              photo.takenAt.month.toString() +
                              "-" +
                              photo.takenAt.year.toString(),
                        );
                      }
                      final List<(String, String)> frames = List.generate(
                        imgPathList.length,
                        (i) => (imgPathList[i], datelist[i]),
                      );
                      final gifBytes = await compute(_createGifIsolate, (
                        frames,
                        montageDuration,
                      ));
                      final filePath = await saveGifToDocuments(gifBytes);
                      await GallerySaver.saveImage(filePath);

                      setState(() {
                        isSaving = false;
                        clear();
                      });
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Your Montage has being saved! Check it in your gallery!",
                            ),
                          );
                        },
                      );
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
