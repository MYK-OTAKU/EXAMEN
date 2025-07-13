class Engin {
  final int? id;
  final String libelle;
  final String statut;

  Engin({
    this.id,
    required this.libelle,
    required this.statut,
  });

  // Conversion depuis JSON (API REST)
  factory Engin.fromJson(Map<String, dynamic> json) {
    return Engin(
      id: json['id'],
      libelle: json['libelle'] ?? '',
      statut: json['statut'] ?? '',
    );
  }

  // Conversion vers JSON (pour sauvegarde locale)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'statut': statut,
    };
  }

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'libelle': libelle,
      'statut': statut,
    };
  }

  // Création depuis Firestore
  factory Engin.fromFirestore(Map<String, dynamic> data) {
    return Engin(
      id: data['id'],
      libelle: data['libelle'] ?? '',
      statut: data['statut'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Engin{id: $id, libelle: $libelle, statut: $statut}';
  }
}
