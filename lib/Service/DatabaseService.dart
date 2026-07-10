import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plant_tracker/Models/growth_record.dart';
import 'package:plant_tracker/Models/photo_model.dart';
import 'package:plant_tracker/Models/plant_model.dart';
import 'package:plant_tracker/Models/wateringrecord.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("database.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
