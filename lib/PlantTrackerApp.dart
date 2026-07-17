import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';
import 'package:plant_tracker/pages/add_new_growth_record.dart';
import 'package:plant_tracker/pages/add_plant_page.dart';
import 'Models/plant_model.dart';
import 'Service/DatabaseService.dart';

class PlantTrackerApp extends StatefulWidget {
  const PlantTrackerApp({super.key});

  @override
  State<PlantTrackerApp> createState() => _PlantTrackerAppState();
}

class _PlantTrackerAppState extends State<PlantTrackerApp> {
  DatabaseService dbService = DatabaseService.instance;
  late List<Plant> plants = [];
  Map<int?, bool> wateringStatus = {};
  Plant plant = Plant(name: "Tomato", plantedDate: DateTime.now());
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
        title: Text("Plant App", style: TextStyle(color: Colors.white)),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];

                return Card(
                  child: ListTile(
                    title: Text(plant.id.toString() + " " + plant.name),
                    subtitle: Text(
                      plant.plantedDate.toString() +
                          "\n" +
                          (plant.notes == null
                              ? "No Notes"
                              : plant.notes.toString()),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
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
                                builder: (context) =>
                                    AddNewGrowthRecord(plantId: plant.id!),
                              ),
                            );
                            refreshPlants();
                          },
                          icon: Icon(Icons.eco, color: Colors.green),
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
                    onTap: () async {
                      final List<GrowthRecord> records = await dbService
                          .readGrowthRecordsForPlant(plant.id!);

                      for (final record in records) {
                        print(record.height);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_sharp),
            label: "Graph",
          ),
        ],
      ),
    );
  }
}
