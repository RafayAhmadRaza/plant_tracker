const String wateringrecordTable = 'wateringrecord';

class wateringrecordFields {
  static final String id = '_id';
  static final String plantId = 'plantId';
  static final String wateredAt = 'wateredAt';
}

class Wateringrecord {
  final int? id;
  final int plantId;
  final DateTime wateredAt;

  const Wateringrecord({
    this.id,
    required this.plantId,
    required this.wateredAt,
  });
}
