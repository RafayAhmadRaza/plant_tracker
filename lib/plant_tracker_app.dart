import 'package:flutter/material.dart';
import 'package:plant_tracker/Service/adservice.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: myIndex, children: widgetList),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AdService.instance.adsRemovedNotifier,
            builder: (context, adsRemoved, _) {
              if (adsRemoved) return const SizedBox.shrink();
              return SizedBox(
                height: 50,
                child: AdWidget(ad: AdService.instance.createBannerAd()),
              );
            },
          ),
        ],
      ),
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
        type: BottomNavigationBarType.fixed,
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_sharp),
            label: "Graph",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_sharp),
            label: "Montage Maker",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}