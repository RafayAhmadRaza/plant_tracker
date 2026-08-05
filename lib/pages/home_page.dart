import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/colors_storage.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';
import 'package:plant_tracker/pages/camera_page.dart';
import 'package:plant_tracker/pages/edit_plant.dart';
import 'add_plant_page.dart';
import 'add_new_growth_record.dart';
import 'package:plant_tracker/Service/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseService dbService = DatabaseService.instance;
  late List<Plant> plants = [];
  Map<int?, bool> wateringStatus = {};
  Plant plant = Plant(name: "Tomato", plantedDate: DateTime.now());
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationService().scheduleNotification(
      title: "Planty Remainder!",
      body: "Don't forget to check your plants. They might be thirsty! 💧!",
      hour: 6,
      minute: 0,
    );
    refreshPlants();
  }

  void refreshPlants() async {
    setState(() {
      isLoading = true;
    });

    this.plants = await dbService.readAllPlants();
    wateringStatus.clear();
    List<Wateringrecord> wrlists_temp = await dbService.readAllwr();
    final today = DateTime.now();
    for (final record in wrlists_temp) {
      final wateredToday =
          record.wateredAt.year == today.year &&
          record.wateredAt.month == today.month &&
          record.wateredAt.day == today.day;

      wateringStatus[record.plantId] = wateredToday;
    }

    debugPrint(wateringStatus.entries.toString());
    setState(() {
      isLoading = false;
    });
  }

  void dispose() {
    dbService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => const AddPlantPage()),
          );
          refreshPlants();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsStorage.name_whimsy_color,
                          ),
                        ),
                        Text(
                          (plant.plantedDate.day.toString() +
                              "-" +
                              plant.plantedDate.month.toString() +
                              "-" +
                              plant.plantedDate.year.toString()),
                          style: TextStyle(
                            color: ColorsStorage.sub_title_whimsy_color,
                          ),
                        ),
                        Text(
                          (plant.notes == null
                              ? "No Notes"
                              : plant.notes.toString()),
                          style: TextStyle(
                            color: ColorsStorage.sub_title_whimsy_color,
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          EditPlant(plantID: plant.id!),
                                    ),
                                  );
                                  refreshPlants();
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  List<Wateringrecord> wrlist = await dbService
                                      .readwateringRecordsForPlant(plant.id!);

                                  if (wrlist.isEmpty ||
                                      (wrlist.last.wateredAt.day !=
                                          DateTime.now().day) ||
                                      (wrlist.last.wateredAt.month !=
                                          DateTime.now().month) ||
                                      wrlist.last.wateredAt.year !=
                                          DateTime.now().year) {
                                    final wr = Wateringrecord(
                                      plantId: plant.id!,
                                      wateredAt: DateTime.now(),
                                    );
                                    await dbService.createwateringRecord(wr);
                                    refreshPlants();
                                  } else {
                                    await dbService.deletewr(
                                      plant.id!,
                                      wrlist.last.id!,
                                    );
                                    refreshPlants();
                                  }
                                },
                                icon: Icon(Icons.water_drop_sharp),
                                color: wateringStatus[plant.id] == true
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddNewGrowthRecord(
                                        plantId: plant.id!,
                                      ),
                                    ),
                                  );
                                  refreshPlants();
                                },
                                icon: Icon(Icons.eco, color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CameraPage(plantId: plant.id!),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.camera_alt),
                              ),

                              IconButton(
                                onPressed: () async {
                                  await dbService.deletePlant(plant.id!);
                                  refreshPlants();
                                },
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
