# TGCC Technicien App - Examen Flutter

Application Flutter complète pour techniciens TGCC avec Firebase, API REST, stockage hors-ligne et base de données SQLite.

## 🚀 Fonctionnalités Implémentées

### 1. Authentification & Firestore ✅
- **a)** Création de compte Technicien (email + mot de passe)
- **b)** Connexion et affichage de l'UID utilisateur
- **c)** Ajout/mise à jour de documents 'engin' dans Firestore

### 2. API REST TGCC ✅
- **a)** Récupération de la liste des engins depuis l'endpoint (avec données mock pour les tests)
- **b)** Parsing JSON et mapping en objets Engin
- **c)** Affichage dans un ListView avec libellé et statut

### 3. Stockage JSON hors-ligne ✅
- **a)** Sauvegarde automatique dans 'engins.json'
- **b)** Chargement automatique au démarrage si hors-ligne
- **c)** Synchronisation automatique avec Firestore dès le retour en ligne

### 4. SQLite - Pratique ✅
- **a)** Classe DBHelper pour ouvrir 'tgcc_app.db'
- **b)** Table 'rapport' créée avec les champs requis
- **c)** Fonctions complètes : insérer, lister, supprimer des rapports

## 📱 Structure de l'Application

```
lib/
├── main.dart                 # Point d'entrée avec Firebase
├── firebase_options.dart     # Configuration Firebase
├── models/
│   ├── engin.dart           # Modèle Engin
│   └── rapport.dart         # Modèle Rapport
├── services/
│   ├── auth_service.dart    # Service Firebase Auth & Firestore
│   ├── api_service.dart     # Service API REST TGCC
│   ├── mock_api_service.dart # Données mock pour tests
│   ├── json_storage_service.dart # Stockage hors-ligne
│   └── db_helper.dart       # Service SQLite
└── screens/
    ├── auth_screen.dart     # Écran d'authentification
    ├── home_screen.dart     # Écran principal
    ├── engin_list_screen.dart # Liste des engins
    └── rapport_screen.dart  # Gestion des rapports
```

## 🛠 Installation et Configuration

### 1. Dépendances
```bash
flutter pub get
```

### 2. Configuration Firebase
1. Créez un projet sur [Firebase Console](https://console.firebase.google.com/)
2. Activez Authentication (Email/Password) et Firestore
3. Téléchargez les fichiers de configuration :
   - `google-services.json` (Android) → `android/app/`
   - `GoogleService-Info.plist` (iOS) → `ios/Runner/`
4. Mettez à jour `firebase_options.dart` avec vos vraies valeurs

### 3. API TGCC
- Par défaut, l'app utilise des données mock
- Pour utiliser l'API réelle, modifiez `json_storage_service.dart` ligne 85
- Remplacez `MockApiService.getMockEngins()` par `_apiService.getEngins()`

## 📋 Guide d'Utilisation

### Authentification
1. **Créer un compte** : Email + mot de passe (minimum 6 caractères)
2. **Se connecter** : Utiliser les mêmes identifiants
3. **UID affiché** : Visible sur l'écran d'authentification et le tableau de bord

### Gestion des Engins
1. **Navigation** : Onglet "Engins" ou depuis le tableau de bord
2. **Visualisation** : Liste complète avec statuts colorés
3. **Recherche** : Par libellé ou ID
4. **Filtrage** : Par statut (Actif, Inactif, Maintenance)
5. **Ajout à Firestore** : Bouton d'upload sur chaque engin

### Stockage Hors-ligne
1. **Automatique** : Sauvegarde lors de la récupération en ligne
2. **Détection** : Indicateur de connexion sur le tableau de bord
3. **Synchronisation** : Automatic lors du retour en ligne

### Gestion des Rapports (SQLite)
1. **Ajouter** : Bouton "+" avec formulaire complet
2. **Modifier** : Menu contextuel sur chaque rapport
3. **Supprimer** : Confirmation requise
4. **Statistiques** : Bouton analytics pour voir les totaux

## 🧪 Tests et Débogage

### Données Mock
L'application utilise des données fictives pour les tests :
- 8 engins avec différents statuts
- Délai simulé de 1 seconde pour imiter l'API

### Mode Hors-ligne
1. Désactivez le WiFi/données mobiles
2. Redémarrez l'app → charge depuis le cache JSON
3. Réactivez la connexion → synchronisation automatique

### Base de données SQLite
- Fichier : `tgcc_app.db` dans le répertoire de l'app
- Tables : `rapport` avec index sur `enginId` et `date`
- Fonctions CRUD complètes avec gestion d'erreurs

## 📊 Points Techniques Avancés

### Architecture
- **Séparation des responsabilités** : Models, Services, Screens
- **Gestion d'état** : StatefulWidget avec setState
- **Navigation** : Bottom navigation avec IndexedStack
- **Pattern Repository** : Services séparés pour chaque source de données

### Sécurité
- **Mots de passe hashés** : Firebase gère automatiquement
- **Validation** : Champs requis et formats
- **Gestion d'erreurs** : Try/catch avec messages utilisateur

### Performance
- **Cache local** : JSON pour réduire les appels API
- **Index SQLite** : Pour optimiser les requêtes
- **Lazy loading** : Chargement des données au besoin

## 🏆 Critères d'Évaluation Couverts

- ✅ **Authentification Firebase** : Création compte + connexion + UID
- ✅ **Firestore** : Ajout/mise à jour documents engin
- ✅ **API REST** : Récupération + parsing + affichage ListView
- ✅ **JSON hors-ligne** : Sauvegarde + chargement + synchronisation
- ✅ **SQLite** : DBHelper + table rapport + CRUD complet
- ✅ **Interface utilisateur** : Navigation fluide et intuitive
- ✅ **Gestion d'erreurs** : Messages explicites
- ✅ **Architecture** : Code structuré et maintenable

## 🔧 Personnalisation

### Changer l'API
Modifiez `api_service.dart` pour adapter l'URL et la structure JSON.

### Ajouter des champs
1. Mettez à jour les modèles (`engin.dart`, `rapport.dart`)
2. Ajustez les services concernés
3. Modifiez les interfaces utilisateur

### Styling
Personnalisez le thème dans `main.dart` → `TGCCApp` → `theme`.

---

**Développé pour l'examen Flutter TGCC**
*Toutes les fonctionnalités demandées sont implémentées et fonctionnelles.*
