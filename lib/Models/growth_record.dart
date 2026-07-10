const String growthTable = 'growth';

class GrowthRecordFields {
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
}
