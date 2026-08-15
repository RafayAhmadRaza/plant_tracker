import 'package:flutter/material.dart';
import 'package:plant_tracker/pages/settings_page.dart';
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
  final montagePlantPicturePageKey = GlobalKey<MontagePlantPicturePageState>();

  late final List<Widget> widgetList = [
    HomePage(),
    GraphPage(key: graphPageKey),
    MontagePlantPicturePage(key: montagePlantPicturePageKey),
    SettingsPage(),
  ];
  static const graphPageIndex = 1;
  static const montagePageIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: myIndex, children: widgetList),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
          if (index == graphPageIndex) {
            graphPageKey.currentState?.loadPlants();
            graphPageKey.currentState?.clear();
            graphPageKey.currentState?.reloadSettings();
          }
          if (index == montagePageIndex) {
            montagePlantPicturePageKey.currentState?.stopSlideshow();
            montagePlantPicturePageKey.currentState?.clear();
            montagePlantPicturePageKey.currentState?.loadPlants();
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
