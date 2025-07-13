import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/engin.dart';
import 'api_service.dart';
import 'mock_api_service.dart'; // Ajout pour les tests
import 'auth_service.dart';

class JsonStorageService {
  static const String _fileName = 'engins.json';
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // a) Sauvegarde de la liste d'engins dans 'engins.json'
  Future<void> saveEnginsToJson(List<Engin> engins) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      // Convertir la liste d'engins en JSON
      List<Map<String, dynamic>> enginsJson = engins.map((engin) => engin.toJson()).toList();
      String jsonString = json.encode({
        'engins': enginsJson,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      // Écrire dans le fichier
      await file.writeAsString(jsonString);
      print('Liste d\'engins sauvegardée dans $_fileName (${engins.length} engins)');
    } catch (e) {
      print('Erreur lors de la sauvegarde JSON: $e');
      throw Exception('Impossible de sauvegarder les engins: $e');
    }
  }

  // b) Chargement du JSON au démarrage si hors-ligne
  Future<List<Engin>> loadEnginsFromJson() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (!await file.exists()) {
        print('Fichier $_fileName n\'existe pas');
        return [];
      }
      
      // Lire le fichier
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = json.decode(contents);
      
      // Extraire les engins
      List<dynamic> enginsJson = jsonData['engins'] ?? [];
      List<Engin> engins = enginsJson.map((item) => Engin.fromJson(item)).toList();
      
      String lastUpdated = jsonData['lastUpdated'] ?? 'Inconnu';
      print('Liste d\'engins chargée depuis $_fileName (${engins.length} engins, dernière MAJ: $lastUpdated)');
      
      return engins;
    } catch (e) {
      print('Erreur lors du chargement JSON: $e');
      return [];
    }
  }

  // Vérifier la connectivité
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Erreur lors de la vérification de la connectivité: $e');
      return false;
    }
  }

  // c) Synchronisation automatique avec Firestore dès le retour en ligne
  Future<List<Engin>> getEnginsWithOfflineSupport() async {
    try {
      bool online = await isOnline();
      
      if (online) {
        print('Mode en ligne - Récupération depuis l\'API...');
        try {
          // Pour les tests, utiliser MockApiService
          // Remplacez par _apiService.getEngins() pour utiliser l'API réelle TGCC
          List<Engin> enginsFromApi = await MockApiService.getMockEngins();
          // List<Engin> enginsFromApi = await _apiService.getEngins(); // API réelle
          
          // Sauvegarder localement
          await saveEnginsToJson(enginsFromApi);
          
          // Synchroniser avec Firestore si l'utilisateur est connecté
          await syncWithFirestore(enginsFromApi);
          
          return enginsFromApi;
        } catch (e) {
          print('Erreur API, basculement vers le stockage local: $e');
          return await loadEnginsFromJson();
        }
      } else {
        print('Mode hors ligne - Chargement depuis le stockage local...');
        return await loadEnginsFromJson();
      }
    } catch (e) {
      print('Erreur lors de la récupération des engins: $e');
      return [];
    }
  }

  // Synchronisation avec Firestore
  Future<void> syncWithFirestore(List<Engin> engins) async {
    try {
      if (_authService.currentUser == null) {
        print('Utilisateur non connecté - Pas de synchronisation Firestore');
        return;
      }

      print('Synchronisation avec Firestore...');
      
      for (Engin engin in engins) {
        await _authService.addOrUpdateEngin(engin);
      }
      
      print('Synchronisation Firestore terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation Firestore: $e');
    }
  }

  // Écouter les changements de connectivité et synchroniser
  Stream<List<Engin>> get enginsStreamWithSync {
    return Connectivity().onConnectivityChanged.asyncMap((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.none) {
        // Retour en ligne - synchroniser
        return await getEnginsWithOfflineSupport();
      } else {
        // Hors ligne - charger depuis le stockage local
        return await loadEnginsFromJson();
      }
    });
  }

  // Supprimer le fichier de cache
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (await file.exists()) {
        await file.delete();
        print('Cache $_fileName supprimé');
      }
    } catch (e) {
      print('Erreur lors de la suppression du cache: $e');
    }
  }

  // Obtenir la date de dernière mise à jour
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (!await file.exists()) {
        return null;
      }
      
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = json.decode(contents);
      
      String? lastUpdated = jsonData['lastUpdated'];
      if (lastUpdated != null) {
        return DateTime.parse(lastUpdated);
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la date de MAJ: $e');
      return null;
    }
  }
}
