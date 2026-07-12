const String photoTable = 'photos';

class PhotoFields {
  static final List<String> values = [id, plantId, imagePath, takenAt];
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

  Map<String, Object?> toJson() => {
    PhotoFields.id: id,
    PhotoFields.plantId: plantId,
    PhotoFields.imagePath: imagePath,
    PhotoFields.takenAt: takenAt.toIso8601String(),
  };

  static Photo fromJson(Map<String, Object?> json) => Photo(
    id: json[PhotoFields.id] as int?,
    plantId: json[PhotoFields.plantId] as int,
    imagePath: json[PhotoFields.imagePath] as String,
    takenAt: DateTime.parse(json[PhotoFields.takenAt] as String),
  );

  Photo copy({int? id, int? plantId, String? imagePath, DateTime? takenAt}) =>
      Photo(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        imagePath: imagePath ?? this.imagePath,
        takenAt: takenAt ?? this.takenAt,
      );
}
