import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                    onTap: () async {
                      dbService.deletePlant(plant.id!);
                      refreshPlants();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                        IconButton(
                          onPressed: () async {
                            await dbService.deletePlant(plant.id!);
                            refreshPlants();
                          },
                          icon: Icon(Icons.delete),
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
