import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';

import 'package:plant_tracker/Service/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => GraphPageState();
}

class GraphPageState extends State<GraphPage> {
  final DatabaseService dbService = DatabaseService.instance;
  SharedPreferences? sp;
  List<Plant> plants = [];
  List<GrowthRecord> growthList = [];
  int selectedPlant = 0;
  List<double> growthHeights = [];
  List<DateTime> dateList = [];
  List<FlSpot> flspotlist = [];
  Set<String> _selected = {"CM"};

  void loadUnit() {
    final savedUnit = sp!.getString("heightUnit") ?? "CM";

    setState(() {
      _selected = {savedUnit};
    });
  }

  void getSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
    loadUnit();
  }

  void reloadSettings() {
    getSharedPreferences();
  }

  void updateSelected(Set<String> newSelection) {
    setState(() {
      _selected = newSelection;
    });
  }

  void convertToinches(List<double> values) {
    final List<double> growthHeightsInches = [];
    for (final i in values) {
      growthHeightsInches.add((i / 2.54));
    }

    setState(() {
      growthHeights = growthHeightsInches;
    });
  }

  @override
  void initState() {
    //

    super.initState();
    plants.clear();
    growthHeights.clear();
    dateList.clear();
    flspotlist.clear();
    loadPlants();
    getSharedPreferences();
  }

  void clear() {
    flspotlist.clear();
  }

  void loadPlants() async {
    final loadedplants = await dbService.readAllPlants();

    setState(() {
      plants = loadedplants;
      selectedPlant = loadedplants.isNotEmpty ? loadedplants.first.id! : 0;

    
    });
  }

  Future<void> loadSpecificRecords(int plandId) async {
    growthList.clear();

    final growthRecords = await dbService.readGrowthRecordsForPlant(plandId);

    if (growthRecords.isEmpty) {
      return;
    }

    setState(() {
      growthList = growthRecords;
    });
  }

  List<FlSpot> createflspotList() {
    flspotlist.clear();
    List<FlSpot> flList = [];

    for (int i = 0; i < growthHeights.length; i++) {
      flList.add(FlSpot(i.toDouble(), growthHeights[i]));
    }

    return flList;
  }

  void getHeights(List<GrowthRecord> grList) {
    growthHeights.clear();
    dateList.clear();

    for (final i in grList) {
      growthHeights.add(i.height);
      dateList.add(i.date);
    }
  }

  double averageHeights(List<double> growthHeights) {
    final totalgrowths = growthHeights.length;

    double sum = 0.0;

    for (int i = 0; i < totalgrowths; i++) {
      sum += growthHeights[i];
    }

    return sum / totalgrowths;
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
    appBar: AppBar(title: const Text("Growth Graph")),
    body: Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          DropdownButton(
            items: plants.map(buildMenuItem).toList(),
            value: selectedPlant,
            onChanged: (value) => setState(() => selectedPlant = value!),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await loadSpecificRecords(selectedPlant);
              if (growthList.isEmpty) return;
              getHeights(growthList);
              if (_selected.first == "Inches") convertToinches(growthHeights);
              setState(() => flspotlist = createflspotList());
            },
            icon: const Icon(Icons.show_chart),
            label: const Text("Generate Graph"),
          ),
          const SizedBox(height: 16),
          if (flspotlist.isEmpty)
            const Text("Your growth graph will appear here 🌱"),
          if (flspotlist.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              height: 380,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dateList.length) {
                            return const SizedBox.shrink();
                          }
                          final date = dateList[index];
                          return SideTitleWidget(
                            meta: meta,
                            child: Text("${date.month}/${date.day}/${date.year}"),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.green.shade100, strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.green.shade100, strokeWidth: 1),
                  ),
                  minY: 0.0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: flspotlist,
                      barWidth: 4,
                      color: const Color(0xFF6FBF73),
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF6FBF73).withAlpha(30),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
              ),
            ),
            const SizedBox(height: 16),
            Text("Average Growth", style: Theme.of(context).textTheme.titleMedium),
            Text(
              "${averageHeights(growthHeights).toStringAsFixed(2)} ${_selected.first}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    ),
  );
}
}