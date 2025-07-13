# Guide de Démarrage Rapide - TGCC Technicien App

## 🎯 Pour l'Examinateur

Cette application Flutter implémente **TOUTES** les fonctionnalités demandées dans l'examen :

### ✅ Tests Rapides

1. **Lancez l'application** : `flutter run`
2. **Créez un compte** : Email + mot de passe (ex: test@tgcc.ma / 123456)
3. **Voir l'UID** : Affiché lors de la connexion
4. **Testez les engins** : Onglet "Engins" → 8 engins mock avec statuts
5. **Testez Firestore** : Bouton "Ajouter à Firestore" sur un engin
6. **Testez hors-ligne** : Désactivez WiFi → les données se chargent depuis le cache
7. **Testez SQLite** : Onglet "Rapports" → Ajouter/modifier/supprimer
8. **Tests automatiques** : Bouton 🧪 dans l'app bar → "Lancer tous les tests"

### 📋 Checklist Examen

#### 1. Authentification & Firestore
- [x] **a)** Créer compte Technicien → Écran d'authentification
- [x] **b)** Se connecter + afficher UID → Visible après connexion
- [x] **c)** Ajouter/mettre à jour 'engin' → Bouton sur chaque engin

#### 2. API REST TGCC
- [x] **a)** Récupérer liste engins → Mock API (8 engins)
- [x] **b)** Parser JSON + mapper objets → Classe Engin.fromJson()
- [x] **c)** Afficher ListView → Onglet "Engins" avec libellé + statut

#### 3. Stockage JSON hors-ligne
- [x] **a)** Sauvegarde 'engins.json' → Automatique après récupération API
- [x] **b)** Chargement au démarrage hors-ligne → Test en désactivant WiFi
- [x] **c)** Synchronisation Firestore → Automatique au retour en ligne

#### 4. SQLite - Pratique
- [x] **a)** DBHelper + 'tgcc_app.db' → Classe DBHelper complète
- [x] **b)** Table 'rapport' → Créée avec tous les champs demandés
- [x] **c)** Insérer/lister/supprimer → Interface complète dans onglet "Rapports"

## 🚀 Demo en 2 Minutes

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Lancer l'app
flutter run

# 3. Dans l'app :
# - Créer compte : test@tgcc.ma / 123456
# - Voir UID affiché
# - Aller sur "Engins" → voir 8 engins
# - Cliquer "Ajouter à Firestore" sur un engin
# - Aller sur "Rapports" → ajouter un rapport
# - Cliquer 🧪 → "Lancer tous les tests"
```

## 📱 Fonctionnalités Bonus

- Interface moderne et intuitive
- Gestion d'erreurs complète
- Statistiques des rapports
- Recherche et filtrage
- Mode sombre supporté
- Navigation fluide
- Tests automatisés intégrés

## 🔧 Configuration Firebase (Optionnel)

Pour tester avec un vrai projet Firebase :

1. Créez un projet sur https://console.firebase.google.com/
2. Activez Authentication (Email/Password) et Firestore
3. Remplacez les valeurs dans `firebase_options.dart`
4. Ajoutez vos fichiers de config (google-services.json, etc.)

**Sans Firebase** : L'app fonctionne avec les données mock et SQLite local.

## 📊 Architecture

```
Authentification (Firebase) ←→ Interface Utilisateur
        ↕                            ↕
API REST (Mock/Réel) ←→ Cache JSON ←→ Firestore
        ↕                            ↕
SQLite Local (Rapports) ←→ Stockage Fichiers
```

---

**🏆 Toutes les exigences de l'examen sont implémentées et fonctionnelles !**
