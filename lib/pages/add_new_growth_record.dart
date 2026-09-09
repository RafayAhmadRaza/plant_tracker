import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Service/database_service.dart';

class AddNewGrowthRecord extends StatefulWidget {
  final int plantId;
  const AddNewGrowthRecord({super.key, required this.plantId});

  @override
  State<AddNewGrowthRecord> createState() => _AddNewGrowthRecordState();
}

class _AddNewGrowthRecordState extends State<AddNewGrowthRecord> {
  final DatabaseService dbService = DatabaseService.instance;
  final _formkey = GlobalKey<FormState>();
  double? growthHeight = 0.0;
  Set<String> _selected = {'CM'};

  void updateSelected(Set<String> newSelection) {
    setState(() => _selected = newSelection);
  }

  double convertTocm(double? valueInches) => valueInches! * 2.54;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Growth Record")),
      body: Form(
        key: _formkey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Enter Growth Height"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                final parsedValue = double.tryParse(value);
                if (parsedValue == null) return;
                growthHeight = _selected.first == 'Inches'
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                GrowthRecord gr = GrowthRecord(
                  plantId: widget.plantId,
                  date: DateTime.now(),
                  height: growthHeight ?? 0.0,
                );

                List<GrowthRecord> growthrecord =
                    await dbService.readGrowthRecordsForPlant(widget.plantId);
                GrowthRecord? todayRecord;

                for (final r in growthrecord) {
                  if (r.date.year == gr.date.year &&
                      r.date.month == gr.date.month &&
                      r.date.day == gr.date.day) {
                    todayRecord = r;
                    break;
                  }
                }

                if (todayRecord == null) {
                  await dbService.createGrowthRecord(gr);
                } else {
                  final updateRecord = GrowthRecord(
                    id: todayRecord.id,
                    plantId: todayRecord.plantId,
                    date: todayRecord.date,
                    height: gr.height,
                  );
                  await dbService.updateGrowthRecord(updateRecord);
                }
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Record"),
            ),
          ],
        ),
      ),
    );
  }
}