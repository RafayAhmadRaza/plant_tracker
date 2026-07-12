const String wateringrecordTable = 'wateringrecord';

class wateringrecordFields {
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
    wateringrecordFields.id: id,
    wateringrecordFields.plantId: plantId,
    wateringrecordFields.wateredAt: wateredAt.toIso8601String(),
  };

  static Wateringrecord fromJson(Map<String, Object?> json) => Wateringrecord(
    id: json[wateringrecordFields.id] as int?,
    plantId: json[wateringrecordFields.plantId] as int,
    wateredAt: DateTime.parse(json[wateringrecordFields.wateredAt] as String),
  );

  Wateringrecord copy({int? id, int? plantId, DateTime? wateredAt}) =>
      Wateringrecord(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        wateredAt: wateredAt ?? this.wateredAt,
      );
}
