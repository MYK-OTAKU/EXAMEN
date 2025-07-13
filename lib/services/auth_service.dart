import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/engin.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // a) Créer un compte Technicien
  Future<UserCredential?> createTechnicienAccount(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ajouter des informations supplémentaires au profil
      if (result.user != null) {
        await result.user!.updateDisplayName('Technicien');
        print('Compte Technicien créé avec succès: ${result.user!.uid}');
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase Auth lors de la création: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cette adresse email est déjà utilisée.');
        case 'weak-password':
          throw Exception('Le mot de passe est trop faible.');
        case 'invalid-email':
          throw Exception('L\'adresse email n\'est pas valide.');
        default:
          throw Exception('Erreur lors de la création du compte: ${e.message}');
      }
    } catch (e) {
      print('Erreur générale lors de la création du compte: $e');
      throw Exception('Erreur inattendue lors de la création du compte. Veuillez réessayer.');
    }
  }

  // b) Se connecter et afficher l'UID
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Connexion réussie - UID: ${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase Auth lors de la connexion: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun utilisateur trouvé avec cette adresse email.');
        case 'wrong-password':
          throw Exception('Mot de passe incorrect.');
        case 'invalid-email':
          throw Exception('L\'adresse email n\'est pas valide.');
        case 'user-disabled':
          throw Exception('Ce compte utilisateur a été désactivé.');
        case 'too-many-requests':
          throw Exception('Trop de tentatives de connexion. Veuillez réessayer plus tard.');
        default:
          throw Exception('Erreur lors de la connexion: ${e.message}');
      }
    } catch (e) {
      print('Erreur générale lors de la connexion: $e');
      throw Exception('Erreur inattendue lors de la connexion. Veuillez réessayer.');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw e;
    }
  }

  // c) Ajouter/mettre à jour un document 'engin' dans Firestore
  Future<void> addOrUpdateEngin(Engin engin) async {
    try {
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Utiliser l'ID de l'engin comme document ID, ou générer un nouveau
      String docId = engin.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      await _firestore
          .collection('engins')
          .doc(docId)
          .set(engin.toFirestore(), SetOptions(merge: true));
          
      print('Engin ajouté/mis à jour dans Firestore: ${engin.libelle}');
    } catch (e) {
      print('Erreur lors de l\'ajout/mise à jour de l\'engin: $e');
      throw e;
    }
  }

  // Récupérer tous les engins depuis Firestore
  Future<List<Engin>> getEnginsFromFirestore() async {
    try {
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      QuerySnapshot snapshot = await _firestore.collection('engins').get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Engin.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des engins: $e');
      throw e;
    }
  }

  // Stream pour écouter les changements d'engins en temps réel
  Stream<List<Engin>> get enginsStream {
    if (currentUser == null) {
      return Stream.value([]);
    }
    
    return _firestore.collection('engins').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Engin.fromFirestore(data);
      }).toList();
    });
  }

  // Supprimer un engin
  Future<void> deleteEngin(String docId) async {
    try {
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _firestore.collection('engins').doc(docId).delete();
      print('Engin supprimé de Firestore');
    } catch (e) {
      print('Erreur lors de la suppression de l\'engin: $e');
      throw e;
    }
  }
}
