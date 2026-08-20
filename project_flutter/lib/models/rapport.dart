class Rapport {
  final int id;
  final int projetId;
  final String periode;
  final String contenu;
  final String createdAt;

  Rapport({
    required this.id,
    required this.projetId,
    required this.periode,
    required this.contenu,
    required this.createdAt,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) {
    return Rapport(
      id: json['id'],
      projetId: json['projet_id'],
      periode: json['periode'],
      contenu: json['contenu_genere'],
      createdAt: json['created_at'],
    );
  }
}