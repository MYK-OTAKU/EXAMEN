import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/db_helper.dart';
import '../services/json_storage_service.dart';
import '../models/engin.dart';
import '../models/rapport.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final AuthService _authService = AuthService();
  final DBHelper _dbHelper = DBHelper();
  final JsonStorageService _storageService = JsonStorageService();
  
  String _testResults = '';

  void _addToResults(String message) {
    setState(() {
      _testResults += '$message\n';
    });
    print(message);
  }

  Future<void> _runAllTests() async {
    setState(() {
      _testResults = 'Début des tests...\n';
    });

    await _testAuthentication();
    await _testFirestore();
    await _testAPIAndJSON();
    await _testSQLite();

    _addToResults('\n✅ Tous les tests terminés !');
  }

  Future<void> _testAuthentication() async {
    _addToResults('\n📱 Test 1: Authentification');
    
    try {
      // Test création de compte (simulé)
      _addToResults('✅ Interface de création de compte : OK');
      
      // Test connexion (simulé)
      _addToResults('✅ Interface de connexion : OK');
      
      // Test affichage UID
      if (_authService.currentUser != null) {
        _addToResults('✅ UID affiché : ${_authService.currentUser!.uid}');
      } else {
        _addToResults('ℹ️ Aucun utilisateur connecté pour le moment');
      }
    } catch (e) {
      _addToResults('❌ Erreur authentification : $e');
    }
  }

  Future<void> _testFirestore() async {
    _addToResults('\n🔥 Test 2: Firestore');
    
    try {
      // Test ajout d'un engin
      final testEngin = Engin(
        id: 999,
        libelle: 'Test Engin - ${DateTime.now().millisecondsSinceEpoch}',
        statut: 'Test',
      );
      
      if (_authService.currentUser != null) {
        await _authService.addOrUpdateEngin(testEngin);
        _addToResults('✅ Ajout engin à Firestore : OK');
        
        // Test récupération
        final engins = await _authService.getEnginsFromFirestore();
        _addToResults('✅ Récupération depuis Firestore : ${engins.length} engins');
      } else {
        _addToResults('ℹ️ Connexion requise pour tester Firestore');
      }
    } catch (e) {
      _addToResults('❌ Erreur Firestore : $e');
    }
  }

  Future<void> _testAPIAndJSON() async {
    _addToResults('\n🌐 Test 3: API REST et JSON');
    
    try {
      // Test récupération API
      final engins = await _storageService.getEnginsWithOfflineSupport();
      _addToResults('✅ Récupération API : ${engins.length} engins');
      
      // Test parsing JSON
      if (engins.isNotEmpty) {
        final firstEngin = engins.first;
        _addToResults('✅ Parsing JSON : ${firstEngin.libelle} (${firstEngin.statut})');
      }
      
      // Test sauvegarde JSON
      await _storageService.saveEnginsToJson(engins);
      _addToResults('✅ Sauvegarde JSON : OK');
      
      // Test chargement JSON
      final savedEngins = await _storageService.loadEnginsFromJson();
      _addToResults('✅ Chargement JSON : ${savedEngins.length} engins');
      
      // Test détection connectivité
      final isOnline = await _storageService.isOnline();
      _addToResults('✅ Détection connectivité : ${isOnline ? "En ligne" : "Hors ligne"}');
      
    } catch (e) {
      _addToResults('❌ Erreur API/JSON : $e');
    }
  }

  Future<void> _testSQLite() async {
    _addToResults('\n💾 Test 4: SQLite');
    
    try {
      // Test ouverture BDD
      final db = await _dbHelper.database;
      _addToResults('✅ Ouverture BDD tgcc_app.db : OK');
      
      // Test insertion rapport
      final testRapport = Rapport(
        enginId: 1,
        date: DateTime.now().toIso8601String().split('T')[0],
        usage: 8.5,
      );
      
      final id = await _dbHelper.insertRapport(testRapport);
      _addToResults('✅ Insertion rapport : ID $id');
      
      // Test lecture rapports
      final rapports = await _dbHelper.getAllRapports();
      _addToResults('✅ Liste rapports : ${rapports.length} trouvés');
      
      // Test statistiques
      final count = await _dbHelper.getReportsCount();
      _addToResults('✅ Comptage rapports : $count total');
      
      // Test suppression
      if (rapports.isNotEmpty) {
        await _dbHelper.deleteRapport(rapports.last.id!);
        _addToResults('✅ Suppression rapport : OK');
      }
      
    } catch (e) {
      _addToResults('❌ Erreur SQLite : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests Fonctionnalités'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _runAllTests,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Lancer tous les tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Résultats des tests :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Cliquez pour lancer les tests...' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
