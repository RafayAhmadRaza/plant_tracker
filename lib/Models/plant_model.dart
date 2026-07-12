const String tablePlant = 'plants';

class PlantFields {
  static final List<String> values = [id, name, plantedDate, notes];

  static final String id = '_id';
  static final String name = 'name';
  static final String plantedDate = 'planted_date';
  static final String notes = 'notes';
}

class Plant {
  final int? id;
  final String name;
  final DateTime plantedDate;
  final String? notes;

  const Plant({
    this.id,
    required this.name,
    required this.plantedDate,
    this.notes,
  });

  Map<String, Object?> toJson() => {
    PlantFields.id: id,
    PlantFields.name: name,
    PlantFields.plantedDate: plantedDate.toIso8601String(),
    PlantFields.notes: notes,
  };

  static Plant fromJson(Map<String, Object?> json) => Plant(
    id: json[PlantFields.id] as int?,
    name: json[PlantFields.name] as String,
    plantedDate: DateTime.parse([PlantFields.plantedDate] as String),
    notes: json[PlantFields.notes] as String,
  );

  Plant copy({int? id, String? name, DateTime? plantedDate, String? notes}) =>
      Plant(
        id: id ?? this.id,
        name: name ?? this.name,
        plantedDate: plantedDate ?? this.plantedDate,
        notes: notes ?? this.notes,
      );
}
