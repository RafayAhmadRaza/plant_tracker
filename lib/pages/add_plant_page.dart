import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  SharedPreferences? sp;
  DatabaseService dbService = DatabaseService.instance;
  Set<String> _selected = {'CM'};
  final _formkey = GlobalKey<FormState>();
  DateTime datePlanted = DateTime.now();
  double? initialHeight = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  bool preferencesLoaded = false;

  Future<void> getSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
    final savedUnit = sp!.getString("heightUnit") ?? "CM";
    if (!mounted) return;
    setState(() {
      _selected = {savedUnit};
      preferencesLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String? checkNameEntered(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter Name Please";
    return null;
  }

  void updateSelected(Set<String> newSelection) {
    setState(() => _selected = newSelection);
  }

  double convertTocm(double? valueInches) => valueInches! * 2.54;

  @override
  Widget build(BuildContext context) {
    if (!preferencesLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Add Plant")),
      body: Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
              controller: nameController,
              validator: checkNameEntered,
            ),
            const SizedBox(height: 16),
            DateTimeFormField(
              decoration: const InputDecoration(labelText: "Date Planted At"),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialPickerDateTime: DateTime.now(),
              onChanged: (value) {
                if (value != null) setState(() => datePlanted = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: "Initial Growth Height"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                final parsedValue = double.tryParse(value);
                if (parsedValue == null) return;
                initialHeight = _selected.first == 'Inches'
                    ? convertTocm(parsedValue)
                    : parsedValue;
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: "CM", label: Text("CM")),
                ButtonSegment<String>(value: "Inches", label: Text("IN")),
              ],
              selected: _selected,
              onSelectionChanged: updateSelected,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: "Notes"),
              controller: noteController,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                if (!_formkey.currentState!.validate()) return;
                final plant = Plant(
                  name: nameController.text,
                  plantedDate: datePlanted,
                  notes: noteController.text.isEmpty ? null : noteController.text,
                );
                final plantCopy = await dbService.createPlant(plant);
                final gr = GrowthRecord(
                  plantId: plantCopy.id!,
                  date: datePlanted,
                  height: initialHeight ?? 0.0,
                );
                await dbService.createGrowthRecord(gr);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.eco),
              label: const Text("Plant It"),
            ),
          ],
        ),
      ),
    );
  }
}