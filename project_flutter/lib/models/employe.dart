class Employe {
  final int id;
  final int userId;
  final String nom;
  final String competences;
  final int niveau;
  final int chargeActuelle;

  Employe({
    required this.id,
    required this.userId,
    required this.nom,
    required this.competences,
    required this.niveau,
    required this.chargeActuelle,
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    return Employe(
      id: json['id'],
      userId: json['user_id'],
      nom: json['user']['name'],
      competences: json['competences'],
      niveau: json['niveau'],
      chargeActuelle: json['charge_actuelle'],
    );
  }
}