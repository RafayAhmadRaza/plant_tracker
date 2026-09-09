import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:plant_tracker/Models/colors_storage.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:share_plus/share_plus.dart';

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
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Montage Maker")),
    body: Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          DropdownButton(
            items: plants.map(buildMenuItem).toList(),
            value: selectedPlant,
            onChanged: isSaving
                ? null
                : (int? value) => setState(() => selectedPlant = value!),
          ),
          const SizedBox(height: 16),
          Slider(
            value: montageDuration,
            min: 0.5,
            max: 1.0,
            divisions: 19,
            label: "${montageDuration.toStringAsFixed(1)}s",
            activeColor: const Color(0xFF6FBF73),
            onChanged: isSaving
                ? null
                : (value) => setState(() => montageDuration = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isSaving
                ? null
                : () async {
                    await loadPhotosPath(selectedPlant);
                    if (imgPathList.isEmpty || isTimerRunning) return;
                    setState(() => isTimerRunning = true);
                    t = Timer.periodic(
                      Duration(milliseconds: (1000 * montageDuration).round()),
                      (timer) {
                        setState(() {
                          currentImageIndex =
                              (currentImageIndex + 1) % imgPathList.length;
                        });
                      },
                    );
                  },
            icon: const Icon(Icons.movie_creation),
            label: const Text("Generate Montage"),
          ),
          const SizedBox(height: 16),
          if (isSaving) ...[
            const Text("Saving Gif, please wait!"),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
          if (imgPathList.isNotEmpty && !isSaving) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  children: [
                    Image(
                      image: FileImage(File(imgPathList[currentImageIndex])),
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${photos[currentImageIndex].takenAt.day}-"
                          "${photos[currentImageIndex].takenAt.month}-"
                          "${photos[currentImageIndex].takenAt.year}",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => isSaving = true);
                    List<String> datelist = [];
                    for (final photo in photos) {
                      datelist.add(
                        photo.takenAt.day.toString().padLeft(2, '0') +
                            "-" +
                            photo.takenAt.month.toString().padLeft(2, '0') +
                            "-" +
                            photo.takenAt.year.toString().padLeft(2, '0'),
                      );
                    }
                    final List<(String, String)> frames = List.generate(
                      imgPathList.length,
                      (i) => (imgPathList[i], datelist[i]),
                    );
                    final gifBytes = await compute(
                      _createGifIsolate,
                      (frames, montageDuration),
                    );
                    final filePath = await saveGifToDocuments(gifBytes);
                    await GallerySaver.saveImage(filePath);
                    setState(() {
                      isSaving = false;
                      clear();
                    });
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text("Montage saved! 🌱 Check your gallery."),
                          actions: [
                            ElevatedButton.icon(
                              onPressed: () {
                                final box =
                                    context.findRenderObject() as RenderBox?;
                                if (filePath.isNotEmpty) {
                                  SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(filePath)],
                                      text: "Check out my plant's growth montage!",
                                      sharePositionOrigin: box != null
                                          ? box.localToGlobal(Offset.zero) & box.size
                                          : null,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.share),
                              label: const Text("Share Gif"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: clear,
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear"),
                ),
              ],
            ),
          ],
          if (imgPathList.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("Your montage will appear here 🎬"),
            ),
        ],
      ),
    ),
  );
}
}
