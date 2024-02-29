import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Repository.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'repositories.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE repositories(id INTEGER PRIMARY KEY, name TEXT, owner TEXT, stars INTEGER)",
        );
      },
      version: 1,
    );
  }

  static Future<void> insertRepositories(List<Repository> repositories) async {
    final Database db = await database;
    final Batch batch = db.batch();
    for (var repository in repositories) {
      // Check if the repository already exists in the database
      final List<Map<String, dynamic>> existingRepository = await db.query(
        'repositories',
        where: 'id = ?',
        whereArgs: [repository.id],
      );
      if (existingRepository.isEmpty) {
        // If the repository doesn't exist, insert it
        batch.insert('repositories', repository.toMap());
      } else {
        // If the repository already exists
        // For demonstration, I'm printing a message here
        print('Repository with id ${repository.id} already exists in the database.');
      }
    }
    await batch.commit();
  }

  static Future<List<Repository>> getRepositories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('repositories');
    return List.generate(maps.length, (i) {
      return Repository(
        id: maps[i]['id'],
        name: maps[i]['name'],
        owner: maps[i]['owner'],
        stars: maps[i]['stars'],
      );
    });
  }
}