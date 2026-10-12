import 'package:flutter/material.dart';
import 'package:plant_tracker/Service/notification_service.dart';
import 'package:plant_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_tracker/Service/adservice.dart';
import 'package:plant_tracker/Service/iap_service.dart';

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
    setState(() => hour = sp!.getInt("hourInt") ?? 6);
  }

  Future<void> setMinute(int min) async {
    await sp!.setInt("minInt", min);
    loadMinute();
  }

  void loadMinute() {
    setState(() => min = sp!.getInt("minInt") ?? 0);
  }

  void updatedNotifications(Set<bool> a) {
    setState(() => notificationsEnabled = a);
    setNotifications(a.first);
    if (a.first == false) {
      NotificationService().cancelAllNotifications();
    } else {
      NotificationService().scheduleNotification(
        title: "Planty Reminder!",
        body: "Don't forget to check your plants. They might be thirsty! 💧",
        hour: hour,
        minute: min,
      );
    }
  }

  void loadNotifications() {
    setState(() => notificationsEnabled = {sp!.getBool("notificationEnabled") ?? true});
  }

  void updateSelected(Set<String> newSelection) {
    setState(() => _selected = newSelection);
    setUnit(_selected);
  }

  Future<void> setUnit(Set<String> unit) async {
    await sp!.setString('heightUnit', unit.first);
  }

  void loadUnit() {
    setState(() => _selected = {sp!.getString("heightUnit") ?? "CM"});
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

  Widget _settingsCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

Widget _buildRemoveAdsCard() {
  return ValueListenableBuilder<bool>(
    valueListenable: AdService.instance.adsRemovedNotifier,
    builder: (context, adsRemoved, _) {
      if (adsRemoved) {
        return _settingsCard(
          title: "Ads",
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text("Ads removed — thank you!"),
            ],
          ),
        );
      }

      return _settingsCard(
        title: "Remove Ads",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enjoy Plant Tracker without banner or interstitial ads. One-time purchase.",
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: IapService.instance.removeAdsProduct == null
                      ? null
                      : () => IapService.instance.buyRemoveAds(),
                  child: Text(
                    IapService.instance.removeAdsProduct != null
                        ? "Buy — ${IapService.instance.removeAdsProduct!.price}"
                        : "Loading...",
                  ),
                ),
                TextButton(
                  onPressed: () => IapService.instance.restorePurchases(),
                  child: const Text("Restore Purchases"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _settingsCard(
            title: "Measurement Unit",
            child: SegmentedButton(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: "CM", label: Text("CM")),
                ButtonSegment<String>(value: "Inches", label: Text("IN")),
              ],
              selected: _selected,
              onSelectionChanged: updateSelected,
            ),
          ),
          _settingsCard(
            title: "Notifications",
            child: SegmentedButton(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: true, label: Text("Yes")),
                ButtonSegment<bool>(value: false, label: Text("No")),
              ],
              selected: notificationsEnabled,
              onSelectionChanged: updatedNotifications,
            ),
          ),
          _settingsCard(
            title: "Reminder Time",
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(TimeOfDay(hour: hour, minute: min).format(context)),
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
          ),
          _settingsCard(
            title: "Appearance",
            child: SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, _) {
                  return SegmentedButton<ThemeMode>(
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment(value: ThemeMode.light, label: Text("Light")),
                      ButtonSegment(value: ThemeMode.dark, label: Text("Dark")),
                      ButtonSegment(value: ThemeMode.system, label: Text("Auto")),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) {
                      saveThemeMode(selection.first);
                    },
                  );
                },
              ),
            ),
          ),
          _buildRemoveAdsCard(),
        ],
      ),
    );
  }
}