import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/rapport.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  // a) Ouvrir la BDD 'tgcc_app.db'
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'tgcc_app.db');
      print('Initialisation de la base de données: $path');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Erreur lors de l\'initialisation de la BDD: $e');
      rethrow;
    }
  }

  // b) Créer la table 'rapport'
  Future<void> _createDatabase(Database db, int version) async {
    try {
      print('Création de la table rapport...');
      
      await db.execute('''
        CREATE TABLE rapport (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          enginId INTEGER NOT NULL,
          date TEXT NOT NULL,
          usage REAL NOT NULL
        )
      ''');
      
      print('Table rapport créée avec succès');
      
      // Optionnel: créer un index pour améliorer les performances
      await db.execute('''
        CREATE INDEX idx_rapport_enginId ON rapport(enginId)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_rapport_date ON rapport(date)
      ''');
      
      print('Index créés avec succès');
    } catch (e) {
      print('Erreur lors de la création de la table: $e');
      rethrow;
    }
  }

  // Mise à jour de la base de données (pour les futures versions)
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print('Mise à jour de la BDD de la version $oldVersion vers $newVersion');
    
    // Ici, vous pourrez ajouter des migrations si nécessaire
    // Par exemple:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE rapport ADD COLUMN nouvelle_colonne TEXT');
    // }
  }

  // c) Insérer un rapport
  Future<int> insertRapport(Rapport rapport) async {
    try {
      final db = await database;
      
      Map<String, dynamic> rapportMap = rapport.toMap();
      rapportMap.remove('id'); // Supprimer l'ID pour l'auto-increment
      
      int id = await db.insert(
        'rapport',
        rapportMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('Rapport inséré avec l\'ID: $id');
      return id;
    } catch (e) {
      print('Erreur lors de l\'insertion du rapport: $e');
      rethrow;
    }
  }

  // c) Lister tous les rapports
  Future<List<Rapport>> getAllRapports() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'rapport',
        orderBy: 'date DESC',
      );
      
      List<Rapport> rapports = maps.map((map) => Rapport.fromMap(map)).toList();
      print('${rapports.length} rapports récupérés');
      
      return rapports;
    } catch (e) {
      print('Erreur lors de la récupération des rapports: $e');
      return [];
    }
  }

  // Lister les rapports par engin
  Future<List<Rapport>> getRapportsByEnginId(int enginId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'rapport',
        where: 'enginId = ?',
        whereArgs: [enginId],
        orderBy: 'date DESC',
      );
      
      List<Rapport> rapports = maps.map((map) => Rapport.fromMap(map)).toList();
      print('${rapports.length} rapports trouvés pour l\'engin $enginId');
      
      return rapports;
    } catch (e) {
      print('Erreur lors de la récupération des rapports par engin: $e');
      return [];
    }
  }

  // Obtenir un rapport par ID
  Future<Rapport?> getRapportById(int id) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'rapport',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return Rapport.fromMap(maps.first);
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du rapport: $e');
      return null;
    }
  }

  // Mettre à jour un rapport
  Future<int> updateRapport(Rapport rapport) async {
    try {
      final db = await database;
      
      int count = await db.update(
        'rapport',
        rapport.toMap(),
        where: 'id = ?',
        whereArgs: [rapport.id],
      );
      
      print('$count rapport(s) mis à jour');
      return count;
    } catch (e) {
      print('Erreur lors de la mise à jour du rapport: $e');
      rethrow;
    }
  }

  // c) Supprimer un rapport
  Future<int> deleteRapport(int id) async {
    try {
      final db = await database;
      
      int count = await db.delete(
        'rapport',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('$count rapport(s) supprimé(s)');
      return count;
    } catch (e) {
      print('Erreur lors de la suppression du rapport: $e');
      rethrow;
    }
  }

  // Supprimer tous les rapports d'un engin
  Future<int> deleteRapportsByEnginId(int enginId) async {
    try {
      final db = await database;
      
      int count = await db.delete(
        'rapport',
        where: 'enginId = ?',
        whereArgs: [enginId],
      );
      
      print('$count rapport(s) supprimé(s) pour l\'engin $enginId');
      return count;
    } catch (e) {
      print('Erreur lors de la suppression des rapports: $e');
      rethrow;
    }
  }

  // Obtenir le nombre total de rapports
  Future<int> getReportsCount() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM rapport'
      );
      
      int count = result.first['count'] as int;
      print('Nombre total de rapports: $count');
      
      return count;
    } catch (e) {
      print('Erreur lors du comptage des rapports: $e');
      return 0;
    }
  }

  // Obtenir des statistiques d'usage par engin
  Future<Map<String, dynamic>> getUsageStatsByEnginId(int enginId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          COUNT(*) as reportCount,
          AVG(usage) as avgUsage,
          MIN(usage) as minUsage,
          MAX(usage) as maxUsage,
          SUM(usage) as totalUsage
        FROM rapport 
        WHERE enginId = ?
      ''', [enginId]);
      
      if (result.isNotEmpty) {
        Map<String, dynamic> stats = result.first;
        print('Statistiques pour l\'engin $enginId: $stats');
        return stats;
      }
      
      return {};
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  // Fermer la base de données
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('Base de données fermée');
    }
  }

  // Supprimer la base de données (utile pour les tests)
  Future<void> deleteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'tgcc_app.db');
      await databaseFactory.deleteDatabase(path);
      _database = null;
      print('Base de données supprimée');
    } catch (e) {
      print('Erreur lors de la suppression de la BDD: $e');
    }
  }
}
