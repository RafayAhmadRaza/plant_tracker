const String growthTable = 'growth';

class GrowthRecordFields {
  static final List<String> values = [id, plantId, date, height];
  static final String id = '_id';
  static final String plantId = 'plantid';
  static final String date = 'date';
  static final String height = 'height';
}

class GrowthRecord {
  final int? id;
  final int plantId;
  final DateTime date;
  final double height;

  const GrowthRecord({
    this.id,
    required this.plantId,
    required this.date,
    required this.height,
  });
  Map<String, Object?> toJson() => {
    GrowthRecordFields.id: id,
    GrowthRecordFields.plantId: plantId,
    GrowthRecordFields.date: date.toIso8601String(),
    GrowthRecordFields.height: height,
  };

  static GrowthRecord fromJson(Map<String, Object?> json) => GrowthRecord(
    id: json[GrowthRecordFields.id] as int?,
    plantId: json[GrowthRecordFields.plantId] as int,
    date: DateTime.parse(json[GrowthRecordFields.date] as String),
    height: (json[GrowthRecordFields.height] as num).toDouble(),
  );

  GrowthRecord copy({int? id, int? plantId, DateTime? date, double? height}) =>
      GrowthRecord(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        date: date ?? this.date,
        height: height ?? this.height,
      );
}
