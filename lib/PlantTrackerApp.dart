import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plant_tracker/pages/SettingsPage.dart';
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
  final MontagePlantPicturePageKey = GlobalKey<MontagePlantPicturePageState>();

  late final List<Widget> widgetList = [
    HomePage(),
    GraphPage(key: graphPageKey),
    MontagePlantPicturePage(key: MontagePlantPicturePageKey),
    Settings_Page(),
  ];
  static const graphPageIndex = 1;
  static const MontagePageIndex = 2;
  static const Settings = 3;

  static const homepageindex = 0;

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
          if (index == MontagePageIndex) {
            MontagePlantPicturePageKey.currentState?.stopSlideshow();
            MontagePlantPicturePageKey.currentState?.clear();
            MontagePlantPicturePageKey.currentState?.loadPlants();
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
