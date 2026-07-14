import 'package:plant_tracker/Models/photo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB("database.db");
    return _database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const notesType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE $tablePlant (
        ${PlantFields.id} $idType,
        ${PlantFields.name} $textType,
        ${PlantFields.plantedDate} $dateType,
        ${PlantFields.notes} $notesType
    )
''');

    await db.execute('''
    
    CREATE TABLE $growthTable
    (
    ${GrowthRecordFields.id} $idType,
    ${GrowthRecordFields.plantId} $integerType,
    ${GrowthRecordFields.date} $dateType,
    ${GrowthRecordFields.height} $realType,

    FOREIGN KEY (${GrowthRecordFields.plantId}) REFERENCES $tablePlant(${PlantFields.id}) ON DELETE CASCADE
    )

    ''');

    await db.execute('''


    CREATE TABLE $photoTable
    (
    ${PhotoFields.id} $idType,
    ${PhotoFields.plantId} $integerType,
    ${PhotoFields.imagePath} $textType,
    ${PhotoFields.takenAt} $dateType,

    FOREIGN KEY (${PhotoFields.plantId}) REFERENCES $tablePlant(${PlantFields.id}) ON DELETE CASCADE
    
    )
    
    
    ''');

    await db.execute('''
    CREATE TABLE $wateringrecordTable(
    ${wateringrecordFields.id} $idType,
    ${wateringrecordFields.plantId} $integerType,
    ${wateringrecordFields.wateredAt} $dateType,

    FOREIGN KEY (${wateringrecordFields.plantId}) REFERENCES $tablePlant(${PlantFields.id}) ON DELETE CASCADE
    )



''');
  }

  Future<Plant> createPlant(Plant plant) async {
    final db = await instance.database;

    final id = await db.insert(tablePlant, plant.toJson());

    return plant.copy(id: id);
  }

  Future<Plant> readPlant(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tablePlant,
      columns: PlantFields.values,
      where: '${PlantFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plant.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Plant>> readAllPlants() async {
    final db = await instance.database;
    final result = await db.query(tablePlant);
    return result.map((json) => Plant.fromJson(json)).toList();
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await instance.database;
    return db.update(
      tablePlant,
      plant.toJson(),
      where: '${PlantFields.id} = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await instance.database;
    return await db.delete(
      tablePlant,
      where: "${PlantFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future<GrowthRecord> createGrowthRecord(GrowthRecord gr) async {
    final db = await instance.database;
    final id = await db.insert(growthTable, gr.toJson());

    return gr.copy(id: id);
  }

  Future<GrowthRecord> readGrowthRecord(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      growthTable,
      columns: GrowthRecordFields.values,
      where: '${GrowthRecordFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GrowthRecord.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<GrowthRecord>> readAllGR() async {
    final db = await instance.database;
    final result = await db.query(growthTable);
    return result.map((json) => GrowthRecord.fromJson(json)).toList();
  }

  Future<List<GrowthRecord>> readGrowthRecordsForPlant(int plantId) async {
    final db = await instance.database;
    final maps = await db.query(
      growthTable,
      where: '${GrowthRecordFields.plantId} = ?',
      whereArgs: [plantId],
      orderBy: '${GrowthRecordFields.date} ASC',
    );
    return maps.map((json) => GrowthRecord.fromJson(json)).toList();
  }

  Future<Photo> createPhoto(Photo photo) async {
    final db = await instance.database;
    final id = await db.insert(photoTable, photo.toJson());

    return photo.copy(id: id);
  }

  Future<Photo> readPhoto(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      photoTable,
      columns: PhotoFields.values,
      where: '${PhotoFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Photo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Photo>> readAllPhoto() async {
    final db = await instance.database;
    final result = await db.query(photoTable);
    return result.map((json) => Photo.fromJson(json)).toList();
  }

  Future<List<Photo>> readPhotosForPlant(int plantId) async {
    final db = await instance.database;
    final maps = await db.query(
      photoTable,
      where: '${PhotoFields.plantId} = ?',
      whereArgs: [plantId],
    );
    return maps.map((json) => Photo.fromJson(json)).toList();
  }

  Future<Wateringrecord> createwateringRecord(Wateringrecord wr) async {
    final db = await instance.database;
    final id = await db.insert(wateringrecordTable, wr.toJson());

    return wr.copy(id: id);
  }

  Future<Wateringrecord> readwr(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      wateringrecordTable,
      columns: wateringrecordFields.values,
      where: '${wateringrecordFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Wateringrecord.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Wateringrecord>> readAllwr() async {
    final db = await instance.database;
    final result = await db.query(wateringrecordTable);
    return result.map((json) => Wateringrecord.fromJson(json)).toList();
  }

  Future<List<Wateringrecord>> readwateringRecordsForPlant(int plantId) async {
    final db = await instance.database;
    final maps = await db.query(
      wateringrecordTable,
      where: '${wateringrecordFields.plantId} = ?',
      whereArgs: [plantId],
    );
    return maps.map((json) => Wateringrecord.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
