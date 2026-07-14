import 'package:flutter/widgets.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'PlantTrackerApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDB("PlantsDatabase.db");

  runApp(const PlantTrackerApp());
}
