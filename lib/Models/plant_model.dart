const String tablePlant = 'plants';

class PlantFields {
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
}
