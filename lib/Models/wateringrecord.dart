const String wateringrecordTable = 'wateringrecord';

class wateringRecordFields {
  static final List<String> values = [id, plantId, wateredAt];
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

  Map<String, Object?> toJson() => {
    wateringRecordFields.id: id,
    wateringRecordFields.plantId: plantId,
    wateringRecordFields.wateredAt: wateredAt.toIso8601String(),
  };

  static Wateringrecord fromJson(Map<String, Object?> json) => Wateringrecord(
    id: json[wateringRecordFields.id] as int?,
    plantId: json[wateringRecordFields.plantId] as int,
    wateredAt: DateTime.parse(json[wateringRecordFields.wateredAt] as String),
  );

  Wateringrecord copy({int? id, int? plantId, DateTime? wateredAt}) =>
      Wateringrecord(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        wateredAt: wateredAt ?? this.wateredAt,
      );
}
