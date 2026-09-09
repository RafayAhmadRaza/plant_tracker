import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'plant_tracker_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDB("PlantsDatabase.db");
  await NotificationService().initialize();
  runApp(const PlantTrackerRoot());
}

class PlantTrackerRoot extends StatelessWidget {
  const PlantTrackerRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Tracker',
      theme: ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFFF8F0),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6FBF73),
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.quicksandTextTheme().copyWith(
    titleMedium: GoogleFonts.baloo2(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF3D5A3A),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: const Color(0xFF3D5A3A),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.baloo2(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF3D5A3A),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6FBF73),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF6FBF73), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selectedBackgroundColor: const Color(0xFF6FBF73),
      selectedForegroundColor: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shadowColor: Colors.black.withAlpha(20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF6FBF73),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
),
      home: const PlantTrackerApp(),
    );
  }
}