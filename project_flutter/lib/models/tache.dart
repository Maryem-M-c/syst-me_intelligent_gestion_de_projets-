class Tache {
  final int id;
  final int projetId;
  final String titre;
  final String? description;
  final int? employeId;
  final String? employeNom;
  final String statut;
  final String echeance;

  Tache({
    required this.id,
    required this.projetId,
    required this.titre,
    this.description,
    this.employeId,
    this.employeNom,
    required this.statut,
    required this.echeance,
  });

  factory Tache.fromJson(Map<String, dynamic> json) {
    return Tache(
      id: json['id'],
      projetId: json['projet_id'],
      titre: json['titre'],
      description: json['description'],
      employeId: json['employe'] != null ? json['employe']['id'] : null,
      employeNom: json['employe'] != null ? json['employe']['user']['name'] : null,
      statut: json['statut'],
      echeance: json['echeance'],
    );
  }
}