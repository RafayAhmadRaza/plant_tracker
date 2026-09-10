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
  double? height = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  bool loaded = false;

  String? checkNameEntered(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter Name Please";
    return null;
  }
Future<void> loadPlant(int plantID) async {
  try {
    plant = await dbService.readPlant(plantID);
    nameController.text = plant!.name;
    noteController.text =
        (plant!.notes == null || plant!.notes!.isEmpty) ? "" : plant!.notes!;

    gr = await dbService.readGrowthRecord(plantID);
    height = gr?.height ?? 0.0;
  } catch (e, st) {
    debugPrint("Error loading plant: $e\n$st");
  } finally {
    if (mounted) {
      setState(() => loaded = true);
    }
  }
}

  @override
  void initState() {
    super.initState();
    loadPlant(widget.plantID);
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Plant")),
      body: Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Name", hintText: "No Notes"),
              controller: nameController,
              validator: checkNameEntered,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: "Enter Growth Height"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                final parsedValue = double.tryParse(value);
                if (parsedValue != null) height = parsedValue;
              },
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
                final editPlant = Plant(
                  id: plant!.id,
                  name: nameController.text,
                  plantedDate: plant!.plantedDate,
                  notes: noteController.text.isEmpty ? null : noteController.text,
                );
                await dbService.updatePlant(editPlant);

                final editedGR = GrowthRecord(
                  plantId: editPlant.id!,
                  date: editPlant.plantedDate,
                  height: height ?? gr!.height,
                );
                await dbService.updateGrowthRecord(editedGR);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}