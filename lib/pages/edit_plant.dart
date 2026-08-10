import 'package:flutter/material.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Service/database_service.dart';
import 'package:flutter/services.dart';

class EditPlant extends StatefulWidget {
  final int plantID;
  const EditPlant({super.key, required this.plantID});

  @override
  State<EditPlant> createState() => EditPlantState();
}

class EditPlantState extends State<EditPlant> {
  DatabaseService dbService = DatabaseService.instance;
  Plant? plant;
  GrowthRecord? gr;
  final _formkey = GlobalKey<FormState>();
  String name = '';
  String note = "";
  double? height = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  String? checkNameEntered(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter Name Please";
    }
    return null;
  }

  Future<void> loadPlant(int plantID) async {
    plant = await dbService.readPlant(plantID);
    nameController.text = plant!.name;
    noteController.text = plant!.notes!.isEmpty
        ? "No Notes"
        : plant!.notes.toString();
    gr = await dbService.readGrowthRecord(plantID);
    height = gr!.height;
  }

  @override
  void initState() {
    loadPlant(widget.plantID);
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
                height = parsedValue;
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
                final editPlant = Plant(
                  id: plant!.id,
                  name: nameController.text,
                  plantedDate: plant!.plantedDate,
                  notes: noteController.text.isEmpty
                      ? "null"
                      : noteController.text,
                );
                await dbService.updatePlant(editPlant);

                GrowthRecord editedGR = GrowthRecord(
                  plantId: editPlant.id!,
                  date: editPlant.plantedDate,
                  height: height ?? gr!.height,
                );

                await dbService.updateGrowthRecord(editedGR);

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
