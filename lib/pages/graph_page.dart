import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';

import 'package:plant_tracker/Service/DatabaseService.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => GraphPageState();
}

class GraphPageState extends State<GraphPage> {
  final DatabaseService dbService = DatabaseService.instance;
  List<Plant> plants = [];
  List<GrowthRecord> growthList = [];
  int selected_plant = 0;
  List<double> growthHeights = [];
  List<DateTime> dateList = [];
  List<FlSpot> flspotlist = [];
  Set<String> _selected = {'CM'};

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
    // TODO: implement initState

    super.initState();
    plants.clear();
    growthHeights.clear();
    dateList.clear();
    flspotlist.clear();
    loadPlants();
  }

  void clear() {
    flspotlist.clear();
  }

  void loadPlants() async {
    final loadedplants = await dbService.readAllPlants();

    setState(() {
      plants = loadedplants;
      selected_plant = loadedplants.first.id!;
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
            ElevatedButton(
              onPressed: () async {
                debugPrint("Holy");
                await loadSpecificRecords(selected_plant);

                if (growthList.isEmpty) {
                  debugPrint("No Records");
                  return;
                }
                debugPrint("First " + growthHeights.toString());
                getHeights(growthList);

                debugPrint(growthHeights.toString());

                if (_selected.first == "Inches") {
                  convertToinches(growthHeights);
                }
                setState(() {
                  flspotlist = createflspotList();
                });
              },

              child: Text(
                "Generate Graph",
                style: TextStyle(color: Colors.black),
              ),
            ),
            if (flspotlist.isEmpty) Text("Graph will be made here"),
            if (flspotlist.isNotEmpty) ...[
              SizedBox(
                height: 400,
                width: 500,
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
                              child: Text(
                                "${date.month}/${date.day}/${date.year}",
                              ),
                              meta: meta,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.green.shade100,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.green.shade100,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    minY: 0.0,

                    lineBarsData: [
                      LineChartBarData(spots: flspotlist, barWidth: 5),
                    ],
                  ),
                  duration: Duration(milliseconds: 150),
                  curve: Curves.linear,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
