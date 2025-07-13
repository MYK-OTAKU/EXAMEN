import 'dart:convert';
import '../models/engin.dart';

class MockApiService {
  // Données factices pour tester l'application
  static const String mockApiResponse = '''
[
  {
    "id": 1,
    "libelle": "Excavatrice CAT 320D",
    "statut": "Actif"
  },
  {
    "id": 2,
    "libelle": "Bulldozer CAT D6T",
    "statut": "Maintenance"
  },
  {
    "id": 3,
    "libelle": "Chargeuse CAT 950M",
    "statut": "Actif"
  },
  {
    "id": 4,
    "libelle": "Niveleuse CAT 140M",
    "statut": "Inactif"
  },
  {
    "id": 5,
    "libelle": "Compacteur CAT CS56B",
    "statut": "Actif"
  },
  {
    "id": 6,
    "libelle": "Pelle hydraulique CAT 336",
    "statut": "Maintenance"
  },
  {
    "id": 7,
    "libelle": "Camion benne CAT 775G",
    "statut": "Actif"
  },
  {
    "id": 8,
    "libelle": "Chariot élévateur CAT EP16",
    "statut": "Actif"
  }
]
''';

  static Future<List<Engin>> getMockEngins() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    final List<dynamic> jsonData = json.decode(mockApiResponse);
    return jsonData.map((item) => Engin.fromJson(item)).toList();
  }
}

// Instructions pour utiliser l'API réelle TGCC :
// 1. Remplacez l'utilisation de MockApiService par ApiService dans json_storage_service.dart
// 2. Vérifiez que l'endpoint https://api-tgcc.ma/engins est accessible
// 3. Ajustez les modèles selon la structure réelle de l'API
