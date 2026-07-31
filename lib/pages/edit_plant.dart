import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_tracker/Models/growth_record.dart';

import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/DatabaseService.dart';
import 'package:date_field/date_field.dart';

class EditPlant extends StatefulWidget {
  int plantID;
  EditPlant({super.key, required this.plantID});

  @override
  State<EditPlant> createState() => EditPlantState();
}

class EditPlantState extends State<EditPlant> {
  DatabaseService dbService = DatabaseService.instance;
  Plant? plant;
  GrowthRecord? gr;
  Set<String> _selected = {'CM'};
  final _formkey = GlobalKey<FormState>();
  String name = '';
  String note = "";
  double? Height = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  String? checkNameEntered(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter Name Please";
    }
    return null;
  }

  Future<void> load_plant(int plantID) async {
    plant = await dbService.readPlant(plantID);
    nameController.text = plant!.name;
    noteController.text = plant!.notes!.isEmpty
        ? "No Notes"
        : plant!.notes.toString();
    gr = await dbService.readGrowthRecord(plantID);
    Height = gr!.height;
  }

  @override
  void initState() {
    // TODO: implement initState
    load_plant(widget.plantID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Plant", style: TextStyle(color: Colors.white)),
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

            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(labelText: "Enter Growth Height"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                final parsedValue = double.tryParse(value);
                if (parsedValue == null) {
                  return;
                }
                Height = parsedValue;
              },
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
                final edit_plant = Plant(
                  id: plant!.id,
                  name: nameController.text,
                  plantedDate: plant!.plantedDate,
                  notes: noteController.text.isEmpty
                      ? "null"
                      : noteController.text,
                );
                final plantCopy = await dbService.updatePlant(edit_plant);

                GrowthRecord edit_gr = GrowthRecord(
                  plantId: edit_plant.id!,
                  date: edit_plant.plantedDate,
                  height: Height ?? gr!.height,
                );

                await dbService.updateGrowthRecord(edit_gr);

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
