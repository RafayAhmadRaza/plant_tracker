const String photoTable = 'photos';

class PhotoFields {
  static final String id = '_id';
  static final String plantId = 'plantId';
  static final String imagePath = 'imagePath';
  static final String takenAt = 'takenAt';
}

class Photo {
  final int? id;
  final int plantId;
  final String imagePath;
  final DateTime takenAt;

  const Photo({
    this.id,
    required this.plantId,
    required this.imagePath,
    required this.takenAt,
  });
}
