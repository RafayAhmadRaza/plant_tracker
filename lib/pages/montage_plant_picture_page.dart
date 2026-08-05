import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';

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
                    child: Image.file(File(imgPathList[currentImageIndex])),
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
                  ElevatedButton(onPressed: () {}, child: Text("Save")),
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
