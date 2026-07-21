import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final DatabaseService dbService = DatabaseService.instance;
  List<Plant> plants = [];
  List<GrowthRecord> growthList = [];
  int selected_plant = 0;
  double? growthHeight = 0.0;
  Set<String> _selected = {'CM'};

  void updateSelected(Set<String> newSelection) {
    setState(() {
      _selected = newSelection;
    });
  }

  double convertToinches(double? valueCM) {
    return valueCM! / 2.54;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadPlants();
  }

  void loadPlants() async {
    final loadedplants = await dbService.readAllPlants();

    setState(() {
      plants = loadedplants;
      selected_plant = plants.first.id!;
    });
  }

  Future<List<GrowthRecord>> loadSpecificRecords(int plandId) async {
    growthList.clear();

    final growthRecords = await dbService.readGrowthRecordsForPlant(plandId);

    if (growthRecords.isEmpty) {
      return growthList;
    }

    growthList = growthRecords;

    return growthList;
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
        title: Text("Graph", style: TextStyle(color: Colors.white)),
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
            const SizedBox(height: 12),

            SegmentedButton(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: "CM", label: Text("CM")),
                ButtonSegment<String>(value: "Inches", label: Text("IN")),
              ],
              selected: _selected,
              onSelectionChanged: updateSelected,
            ),
          ],
        ),
      ),
    );
  }
}
