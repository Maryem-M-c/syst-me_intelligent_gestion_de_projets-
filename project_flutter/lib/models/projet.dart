class Projet {
  final int id;
  final String nom;
  final String client;
  final String? description;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final String priorite;

  Projet({
    required this.id,
    required this.nom,
    required this.client,
    this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.priorite,
  });

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      id: json['id'],
      nom: json['nom'],
      client: json['client'],
      description: json['description'],
      dateDebut: json['date_debut'],
      dateFin: json['date_fin'],
      statut: json['statut'],
      priorite: json['priorite'],
    );
  }
}