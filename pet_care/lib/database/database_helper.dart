import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/mascota_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Directorio donde se guardará la base de datos en el móvil
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pet_care_pro.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Tabla de Mascotas
    await db.execute('''
      CREATE TABLE mascotas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        especie TEXT NOT NULL,
        raza TEXT,
        fotoPath TEXT
      )
    ''');

    // 2. Tabla de Calendario de Salud (Vacunas, Citas)
    await db.execute('''
      CREATE TABLE calendario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mascotaId INTEGER,
        titulo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        tipo TEXT, -- 'vacuna', 'desparasitacion', 'veterinario'
        completado INTEGER DEFAULT 0,
        FOREIGN KEY (mascotaId) REFERENCES mascotas (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabla de Historial Médico
    await db.execute('''
      CREATE TABLE historial (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mascotaId INTEGER,
        fecha TEXT NOT NULL,
        diagnostico TEXT,
        tratamiento TEXT,
        veterinario TEXT,
        FOREIGN KEY (mascotaId) REFERENCES mascotas (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- FUNCIONES CRUD BÁSICAS PARA EMPEZAR ---

  Future<int> insertarMascota(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('mascotas', row);
  }

  Future<List<Map<String, dynamic>>> consultarMascotas() async {
    Database db = await database;
    return await db.query('mascotas');
  }

// --- OPERACIONES PARA MASCOTAS ---
  Future<int> actualizarMascota(Mascota mascota) async {
    Database db = await database;
    return await db.update('mascotas', mascota.toMap(), where: 'id = ?', whereArgs: [mascota.id]);
  }

  Future<int> eliminarMascota(int id) async {
    Database db = await database;
    return await db.delete('mascotas', where: 'id = ?', whereArgs: [id]);
  }

  // --- OPERACIONES PARA CALENDARIO (Salud) ---
  Future<int> insertarEvento(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('calendario', row);
  }

  Future<List<Map<String, dynamic>>> consultarEventosPorMascota(int mascotaId) async {
    Database db = await database;
    return await db.query('calendario', where: 'mascotaId = ?', whereArgs: [mascotaId], orderBy: 'fecha ASC');
  }
}