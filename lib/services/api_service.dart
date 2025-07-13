import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/engin.dart';

class ApiService {
  static const String baseUrl = 'https://api-tgcc.ma';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // a) Récupérer la liste des engins depuis l'API
  Future<List<Engin>> getEngins() async {
    try {
      print('Récupération des engins depuis l\'API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/engins'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      print('Statut de la réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        // b) Parser le JSON et mapper en objets Engin
        final List<dynamic> jsonData = json.decode(response.body);
        
        List<Engin> engins = jsonData.map((item) {
          return Engin.fromJson(item as Map<String, dynamic>);
        }).toList();
        
        print('${engins.length} engins récupérés avec succès');
        return engins;
      } else {
        throw Exception('Erreur lors de la récupération des engins: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Impossible de récupérer les engins: $e');
    }
  }

  // Récupérer un engin spécifique par ID
  Future<Engin?> getEnginById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/engins/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Engin.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur lors de la récupération de l\'engin: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Impossible de récupérer l\'engin: $e');
    }
  }

  // Créer un nouvel engin (si l'API le permet)
  Future<Engin?> createEngin(Engin engin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/engins'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(engin.toJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Engin.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la création de l\'engin: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Impossible de créer l\'engin: $e');
    }
  }

  // Mettre à jour un engin (si l'API le permet)
  Future<Engin?> updateEngin(int id, Engin engin) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/engins/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(engin.toJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Engin.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'engin: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Impossible de mettre à jour l\'engin: $e');
    }
  }

  // Supprimer un engin (si l'API le permet)
  Future<bool> deleteEngin(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/engins/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Impossible de supprimer l\'engin: $e');
    }
  }
}
