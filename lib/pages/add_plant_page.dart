import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_tracker/Models/growth_record.dart';

import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:date_field/date_field.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  DatabaseService dbService = DatabaseService.instance;
  Set<String> _selected = {'CM'};
  final _formkey = GlobalKey<FormState>();
  String name = '';
  DateTime datePlanted = DateTime.now();
  String note = "";
  double? initialHeight = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String? checkNameEntered(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter Name Please";
    }
    return null;
  }

  void updateSelected(Set<String> newSelection) {
    setState(() {
      _selected = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Plant", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              controller: nameController,
              validator: checkNameEntered,
            ),

            const SizedBox(height: 20),

            DateTimeFormField(
              decoration: const InputDecoration(labelText: "Date Planted At"),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialPickerDateTime: DateTime.now(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    datePlanted = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                labelText: "Enter Intial Growth Height",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                initialHeight = double.tryParse(value);
              },
            ),

            const SizedBox(height: 12),

            SegmentedButton(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: "CM", label: Text("CM")),
                ButtonSegment<String>(value: "Inches", label: Text("IN")),
              ],
              selected: _selected,
              onSelectionChanged: updateSelected,
            ),

            const SizedBox(height: 12),

            TextFormField(
              decoration: InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              controller: noteController,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final plant = Plant(
                  name: nameController.text,
                  plantedDate: datePlanted,
                  notes: noteController.text.isEmpty
                      ? null
                      : noteController.text,
                );
                final plantCopy = await dbService.createPlant(plant);
                GrowthRecord gr = GrowthRecord(
                  plantId: plantCopy.id!,
                  date: datePlanted,
                  height: initialHeight ?? 0.0,
                );
                await dbService.createGrowthRecord(gr);

                Navigator.pop(context);
              },
              child: Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
