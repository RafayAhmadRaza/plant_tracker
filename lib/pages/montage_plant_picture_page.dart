import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';

class MontagePlantPicturePage extends StatefulWidget {
  const MontagePlantPicturePage({super.key});

  @override
  State<MontagePlantPicturePage> createState() =>
      _MontagePlantPicturePageState();
}

class _MontagePlantPicturePageState extends State<MontagePlantPicturePage> {
  DatabaseService dbService = DatabaseService.instance;
  List<String> imgPathList = [];
  int selected_plant = 0;
  List<Photo> photos = [];
  List<Plant> plants = [];

  void loadPlants() async {
    final loadedplants = await dbService.readAllPlants();

    setState(() {
      plants = loadedplants;
      selected_plant = loadedplants.first.id!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPlants();
  }

  void load_photos_path(int id) async {
    photos = await dbService.readPhotosForPlant(id);

    for (Photo photo in photos) {
      imgPathList.add(photo.imagePath);
    }
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
              value: selected_plant,
              onChanged: (value) {
                setState(() {
                  selected_plant = value!;
                });
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                load_photos_path(selected_plant);
                if (imgPathList.isEmpty) {
                  return;
                }
              },
              child: Text("Generate Montage"),
            ),
            SizedBox(height: 12),
            if (imgPathList.isNotEmpty) ...[
              SizedBox(
                height: 300,
                width: 300,
                child: Image.file(File(imgPathList.first)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
