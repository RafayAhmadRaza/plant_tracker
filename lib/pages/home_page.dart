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

  static const pastelBlue = Color(0xFF8FB8D9);

  Widget _actionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color.withAlpha(35),
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

  Future<void> refreshPlants() async {
    setState(() => isLoading = true);

    final loadedPlants = await dbService.readAllPlants();
    final wrListTemp = await dbService.readAllwr();

    wateringStatus.clear();
    final today = DateTime.now();
    for (final record in wrListTemp) {
      final wateredToday =
          record.wateredAt.year == today.year &&
          record.wateredAt.month == today.month &&
          record.wateredAt.day == today.day;
      wateringStatus[record.plantId] = wateredToday;
    }

    setState(() {
      plants = loadedPlants;
      isLoading = false;
    });
  }

  void dispose() {
    dbService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedColor = scheme.onSurface.withAlpha(160);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => const AddPlantPage()),
          );
          await refreshPlants();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: plants.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 72,
                      color: scheme.primary.withAlpha(120),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No plants yet",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the + button below to add your first plant 🌱",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final watered = wateringStatus[plant.id] == true;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 0,
                  color: scheme.surfaceContainerLow,
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
                              backgroundColor: scheme.primary.withAlpha(40),
                              child: Icon(Icons.eco, color: scheme.primary),
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
                        if (plant.notes != null && plant.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            plant.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'No Notes',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: mutedColor,
                            ),
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionIcon(Icons.edit, mutedColor, () async {
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
                              watered ? pastelBlue : scheme.outline,
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
                            _actionIcon(Icons.eco, scheme.primary, () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddNewGrowthRecord(plantId: plant.id!),
                                ),
                              );
                              refreshPlants();
                            }),
                            _actionIcon(Icons.camera_alt, mutedColor, () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraPage(plantId: plant.id!),
                                ),
                              );
                            }),
                            _actionIcon(Icons.delete, scheme.error, () async {
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