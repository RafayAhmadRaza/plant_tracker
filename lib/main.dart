import 'package:flutter/material.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'plant_tracker_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDB("PlantsDatabase.db");
  await NotificationService().initialize();

  runApp(const MaterialApp(home: PlantTrackerApp()));
}
