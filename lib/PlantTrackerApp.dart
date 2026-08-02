import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plant_tracker/pages/graph_page.dart';
import 'package:plant_tracker/pages/home_page.dart';
import 'package:plant_tracker/pages/montage_plant_picture_page.dart';

class PlantTrackerApp extends StatefulWidget {
  const PlantTrackerApp({super.key});

  @override
  State<PlantTrackerApp> createState() => _PlantTrackerAppState();
}

class _PlantTrackerAppState extends State<PlantTrackerApp> {
  int myIndex = 0;
  final graphPageKey = GlobalKey<GraphPageState>();

  late final List<Widget> widgetList = [
    HomePage(),
    GraphPage(key: graphPageKey),
    MontagePlantPicturePage(),
  ];
  static const graphPageIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(children: widgetList, index: myIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
          if (index == graphPageIndex) {
            graphPageKey.currentState?.loadPlants();
            graphPageKey.currentState?.clear();
          }
        },
        showUnselectedLabels: false,
        type: BottomNavigationBarType.shifting,
        currentIndex: myIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_sharp),
            label: "Graph",
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_sharp),
            label: "Montage Maker",
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
