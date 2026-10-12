import 'package:plant_tracker/Service/iap_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plant_tracker/Service/adservice.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plant_tracker_app.dart';

// Global notifier so any page can toggle theme mode
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

const _themeModePrefKey = "themeMode";

Future<void> loadSavedThemeMode() async {
  final sp = await SharedPreferences.getInstance();
  final saved = sp.getString(_themeModePrefKey);
  switch (saved) {
    case "light":
      themeModeNotifier.value = ThemeMode.light;
      break;
    case "dark":
      themeModeNotifier.value = ThemeMode.dark;
      break;
    default:
      themeModeNotifier.value = ThemeMode.system;
  }
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_themeModePrefKey, mode.name);
  themeModeNotifier.value = mode;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDB("PlantsDatabase.db");
  await NotificationService().initialize();
  await loadSavedThemeMode();
  await AdService.instance.init();
  await IapService.instance.init();
  runApp(const PlantTrackerRoot());
}

class PlantTrackerRoot extends StatelessWidget {
  const PlantTrackerRoot({super.key});

  // Light palette (Mauve Dust set)
  static const mauveDust = Color(0xFFCB96BA);
  static const venusFlower = Color(0xFFE0E4E7);
  static const greenBeryl = Color(0xFFD0DDC4);
  static const forestFrolic = Color(0xFF77A39A);
  static const deepForest = Color(0xFF3D5A50); // darker nav bar for light mode

  // Dark palette (Lily Pond set)
  static const darkGreen = Color(0xFF0A3323);
  static const mossGreen = Color(0xFF839958);
  static const beige = Color(0xFFF7F4D5);
  static const rosyBrown = Color(0xFFD3968C);
  static const midnightGreen = Color(0xFF105666);

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: forestFrolic,
      onPrimary: Colors.white,
      secondary: mauveDust,
      onSecondary: Colors.white,
      tertiary: mauveDust,
      onTertiary: Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.white,
      surface: venusFlower,
      onSurface: const Color(0xFF2B3634),
      surfaceContainerLow: Colors.white,
      surfaceContainerHighest: greenBeryl,
      outline: const Color(0xFFB9C4C0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFBF9F6),
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        titleMedium: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3D5A50),
        ),
        titleLarge: GoogleFonts.baloo2(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3D5A50),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF3D5A50),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3D5A50),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestFrolic,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestFrolic,
          side: BorderSide(color: forestFrolic, width: 1.5),
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
          borderSide: const BorderSide(color: forestFrolic, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          selectedBackgroundColor: forestFrolic,
          selectedForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          textStyle: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600),
          visualDensity: VisualDensity.compact,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withAlpha(20),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mauveDust,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: deepForest,
        selectedItemColor: mauveDust,
        unselectedItemColor: Colors.white70,
      ),
      dividerColor: const Color(0xFFE3DED6),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: mossGreen,
      onPrimary: darkGreen,
      secondary: rosyBrown,
      onSecondary: darkGreen,
      tertiary: rosyBrown,
      onTertiary: darkGreen,
      error: const Color(0xFFE39187),
      onError: darkGreen,
      surface: darkGreen,
      onSurface: beige,
      surfaceContainerLow: midnightGreen,
      surfaceContainerHighest: const Color(0xFF14432F),
      outline: const Color(0xFF3D6B58),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkGreen,
      textTheme: GoogleFonts.quicksandTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        titleMedium: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: beige,
        ),
        titleLarge: GoogleFonts.baloo2(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: beige,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: beige,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: beige,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mossGreen,
          foregroundColor: darkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mossGreen,
          side: const BorderSide(color: mossGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: midnightGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mossGreen, width: 2),
        ),
        hintStyle: TextStyle(color: beige.withAlpha(140)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          selectedBackgroundColor: mossGreen,
          selectedForegroundColor: darkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          textStyle: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600),
          visualDensity: VisualDensity.compact,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: midnightGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: rosyBrown,
        foregroundColor: darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: midnightGreen,
        selectedItemColor: rosyBrown,
        unselectedItemColor: beige.withAlpha(140),
      ),
      dividerColor: const Color(0xFF1E4A38),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Plant Tracker',
          themeMode: mode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const PlantTrackerApp(),
        );
      },
    );
  }
}