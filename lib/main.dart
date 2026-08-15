import 'package:flutter/material.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'plant_tracker_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("1");

  await DatabaseService.instance.initDB("PlantsDatabase.db");
  print("2");

  await NotificationService().initialize();
  print("3");

  runApp(const MaterialApp(home: PlantTrackerApp()));
  print("4");
}
