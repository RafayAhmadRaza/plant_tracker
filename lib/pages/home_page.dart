import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/colors_storage.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';
import 'package:plant_tracker/pages/camera_page.dart';
import 'package:plant_tracker/pages/edit_plant.dart';
import 'package:intl/intl.dart';
import 'add_plant_page.dart';
import 'add_new_growth_record.dart';

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


Widget _actionIcon(IconData icon, Color color, VoidCallback onPressed) {
  return Material(
    color: color.withAlpha(50),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: 22),
      ),
    ),
  );
}

  @override
  void initState() {
    super.initState();
    refreshPlants();
  }

  void refreshPlants() async {
    setState(() {
      isLoading = true;
    });

    plants = await dbService.readAllPlants();
    wateringStatus.clear();
    List<Wateringrecord> wrListTemp = await dbService.readAllwr();
    final today = DateTime.now();
    for (final record in wrListTemp) {
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
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Home Page", style: TextStyle(color: Colors.white)),
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
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        final watered = wateringStatus[plant.id] == true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.eco, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            DateFormat.yMMMd().format(plant.plantedDate),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (plant.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    plant.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionIcon(Icons.edit, Colors.grey.shade700, () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => EditPlant(plantID: plant.id!),
                        ),
                      );
                      refreshPlants();
                    }),
                    _actionIcon(
                      Icons.water_drop,
                      watered ? Colors.blue : Colors.grey,
                      () async {
                        List<Wateringrecord> wrlist =
                            await dbService.readwateringRecordsForPlant(plant.id!);

                        if (wrlist.isEmpty ||
                            wrlist.last.wateredAt.day != DateTime.now().day ||
                            wrlist.last.wateredAt.month != DateTime.now().month ||
                            wrlist.last.wateredAt.year != DateTime.now().year) {
                          final wr = Wateringrecord(
                            plantId: plant.id!,
                            wateredAt: DateTime.now(),
                          );
                          await dbService.createwateringRecord(wr);
                        } else {
                          await dbService.deletewr(plant.id!, wrlist.last.id!);
                        }
                        refreshPlants();
                      },
                    ),
                    _actionIcon(Icons.eco, Colors.green, () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddNewGrowthRecord(plantId: plant.id!),
                        ),
                      );
                      refreshPlants();
                    }),
                    _actionIcon(Icons.camera_alt, Colors.grey.shade700, () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraPage(plantId: plant.id!),
                        ),
                      );
                    }),
                    _actionIcon(Icons.delete, Colors.red, () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Plant?"),
                          content: const Text(
                            "Are you sure you want to delete this plant? (This Action is not reversible!)",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete == true) {
                        await dbService.deletePlant(plant.id!);
                        refreshPlants();
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}