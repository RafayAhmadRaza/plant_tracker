import 'package:flutter/material.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? sp;
  Set<String> _selected = {"CM"};
  Set<bool> notificationsEnabled = {true};
  int hour = 6;
  int min = 0;

  Future<void> setNotifications(bool notificationEnabled) async {
    await sp!.setBool("notificationEnabled", notificationEnabled);
  }

  Future<void> setHour(int hour) async {
    await sp!.setInt("hourInt", hour);
    loadHour();
  }

  void loadHour() {
    final savedHour = sp!.getInt("hourInt") ?? 6;

    setState(() {
      hour = savedHour;
      debugPrint("$hour");
    });
  }

  Future<void> setMinute(int min) async {
    await sp!.setInt("minInt", min);
    loadMinute();
  }

  void loadMinute() {
    final savedMinute = sp!.getInt("minInt") ?? 0;

    setState(() {
      min = savedMinute;
      debugPrint("$min");
    });
  }

  void updatedNotifications(Set<bool> a) {
    setState(() {
      notificationsEnabled = a;
    });
    setNotifications(a.first);
    if (a.first == false) {
      NotificationService().cancelAllNotifications();
    } else {
      NotificationService().scheduleNotification(
        title: "Planty Remainder!",
        body: "Don't forget to check your plants. They might be thirsty! 💧!",
        hour: hour,
        minute: min,
      );
    }
  }

  void loadNotifications() {
    final savedBool = sp!.getBool("notificationEnabled") ?? true;

    setState(() {
      notificationsEnabled = {savedBool};
    });
  }

  void updateSelected(Set<String> newSelection) {
    setState(() {
      _selected = newSelection;
    });
    setUnit(_selected);
  }

  Future<void> setUnit(Set<String> unit) async {
    await sp!.setString('heightUnit', unit.first);
    debugPrint(sp!.getString("heightUnit"));
  }

  void loadUnit() {
    final savedUnit = sp!.getString("heightUnit") ?? "CM";

    setState(() {
      _selected = {savedUnit};
    });
  }

  void getSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
    loadUnit();
    loadHour();
    loadMinute();
    loadNotifications();
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text("Unit"),
            //Unit Prefernce
            SegmentedButton(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: "CM", label: Text("CM")),
                ButtonSegment<String>(value: "Inches", label: Text("IN")),
              ],
              selected: _selected,
              onSelectionChanged: updateSelected,
            ),

            const SizedBox(height: 40),
            Text("Notifications"),

            //Notification Allowed
            SegmentedButton(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: true, label: Text("Yes")),
                ButtonSegment<bool>(value: false, label: Text("No")),
              ],
              selected: notificationsEnabled,
              onSelectionChanged: updatedNotifications,
            ),
            const SizedBox(height: 40),

            //Notification Time
            ListTile(
              title: Text("Notification Time"),
              subtitle: Text(
                TimeOfDay(hour: hour, minute: min).format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: notificationsEnabled.first == false
                  ? null
                  : () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: hour, minute: min),
                      );
                      if (pickedTime != null) {
                        await setHour(pickedTime.hour);
                        await setMinute(pickedTime.minute);
                        await setNotifications(true);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
