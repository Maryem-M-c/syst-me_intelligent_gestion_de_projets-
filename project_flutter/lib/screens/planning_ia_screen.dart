import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlanningIaScreen extends StatefulWidget {
  const PlanningIaScreen({super.key});

  @override
  State<PlanningIaScreen> createState() => _PlanningIaScreenState();
}

class _PlanningIaScreenState extends State<PlanningIaScreen> {
  bool _loadingHumeur = true;
  bool _envoiHumeur = false;
  bool _loadingPlanning = false;
  bool _ameliorant = false;

  String? _humeurDuJour;
  Map<String, dynamic>? _planning;
  String? _conseilAmeliore;

  final List<Map<String, dynamic>> _humeurs = const [
    {'valeur': 'excellent', 'label': 'Excellent', 'emoji': '😄'},
    {'valeur': 'bien', 'label': 'Bien', 'emoji': '🙂'},
    {'valeur': 'neutre', 'label': 'Neutre', 'emoji': '😐'},
    {'valeur': 'fatigue', 'label': 'Fatigué(e)', 'emoji': '😴'},
    {'valeur': 'stresse', 'label': 'Stressé(e)', 'emoji': '😣'},
  ];

  @override
  void initState() {
    super.initState();
    _chargerHumeurDuJour();
  }

  Future<void> _chargerHumeurDuJour() async {
    setState(() => _loadingHumeur = true);
    try {
      final result = await ApiService.get('mon-humeur/aujourdhui');
      setState(() {
        _humeurDuJour = result != null ? result['humeur'] : null;
        _loadingHumeur = false;
      });
      if (_humeurDuJour != null) {
        _genererPlanning();
      }
    } catch (e) {
      setState(() => _loadingHumeur = false);
    }
  }

  Future<void> _choisirHumeur(String valeur) async {
    setState(() => _envoiHumeur = true);
    await ApiService.post('mon-humeur', {'humeur': valeur});
    setState(() {
      _humeurDuJour = valeur;
      _envoiHumeur = false;
    });
    _genererPlanning();
  }

  Future<void> _genererPlanning() async {
    setState(() {
      _loadingPlanning = true;
      _conseilAmeliore = null;
    });
    try {
      final result = await ApiService.get('mon-planning');
      setState(() {
        _planning = result;
        _loadingPlanning = false;
      });
    } catch (e) {
      setState(() => _loadingPlanning = false);
    }
  }

  Future<void> _ameliorerAvecGemini() async {
    if (_planning == null) return;
    setState(() => _ameliorant = true);
    try {
      final result = await ApiService.post('ameliorer-conseil', {
        'conseil_base': _planning!['conseil'],
        'humeur': _planning!['humeur'],
        'nombre_taches': _planning!['nombre_taches'],
        'charge_actuelle': _planning!['charge_actuelle'],
      });
      setState(() => _conseilAmeliore = result['conseil_ameliore']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff2A200C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Text("Impossible d'améliorer le conseil pour le moment",
                style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }
    setState(() => _ameliorant = false);
  }

  Color _couleurBloc(String type) {
    return type == 'pause' ? const Color(0xff4ADE80) : const Color(0xffF59E0B);
  }

  IconData _iconeBloc(String type) {
    return type == 'pause' ? Icons.self_improvement_rounded : Icons.task_alt_rounded;
  }

  String _emojiHumeur(String? valeur) {
    final trouve = _humeurs.firstWhere(
      (h) => h['valeur'] == valeur,
      orElse: () => {'emoji': '😐'},
    );
    return trouve['emoji'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1A1208),

    

      // ================= BODY =================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff231907), Color(0xff1A1208)],
          ),
        ),
        child: _loadingHumeur
            ? const Center(child: CircularProgressIndicator(color: Color(0xffF59E0B)))
            : RefreshIndicator(
                color: const Color(0xffF59E0B),
                backgroundColor: const Color(0xff2A200C),
                onRefresh: _chargerHumeurDuJour,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // --------- Mood Check ---------
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Comment vous sentez-vous aujourd'hui ?",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _humeurs.map((h) {
                              final selectionne = _humeurDuJour == h['valeur'];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _envoiHumeur ? null : () => _choisirHumeur(h['valeur']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectionne
                                        ? const Color(0xffF59E0B).withOpacity(.20)
                                        : Colors.white.withOpacity(.04),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectionne
                                          ? const Color(0xffF59E0B)
                                          : Colors.white.withOpacity(.10),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(h['emoji'], style: const TextStyle(fontSize: 26)),
                                      const SizedBox(height: 6),
                                      Text(h['label'],
                                          style: TextStyle(
                                            color: selectionne ? const Color(0xffF59E0B) : Colors.white70,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_humeurDuJour != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              "Humeur enregistrée aujourd'hui : ${_emojiHumeur(_humeurDuJour)}",
                              style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12.5),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --------- Planning ---------
                    if (_loadingPlanning)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator(color: Color(0xffF59E0B))),
                      ),

                    if (!_loadingPlanning && _planning != null) ...[
                      // Carte conseil
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xffF59E0B).withOpacity(.10),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xffF59E0B).withOpacity(.30), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tips_and_updates_outlined, color: Color(0xffF59E0B), size: 20),
                                const SizedBox(width: 10),
                                const Text("Conseil du jour",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _planning!['conseil'],
                              style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 13, height: 1.5),
                            ),

                            if (_conseilAmeliore != null) ...[
                              const SizedBox(height: 14),
                              Divider(color: Colors.white.withOpacity(.08)),
                              const SizedBox(height: 10),
                              Row(
                                children: const [
                                  Icon(Icons.auto_awesome, color: Color(0xff60D9FF), size: 16),
                                  SizedBox(width: 6),
                                  Text("Conseil amélioré par Gemini",
                                      style: TextStyle(color: Color(0xff60D9FF), fontSize: 11.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _conseilAmeliore!,
                                style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13, height: 1.5),
                              ),
                            ],

                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _ameliorant ? null : _ameliorerAvecGemini,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xff60D9FF), width: 1.2),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: _ameliorant
                                    ? const SizedBox(
                                        width: 14, height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff60D9FF)),
                                      )
                                    : const Icon(Icons.auto_awesome, color: Color(0xff60D9FF), size: 17),
                                label: Text(
                                  _ameliorant ? 'Amélioration en cours...' : 'Améliorer les conseils avec Gemini',
                                  style: const TextStyle(color: Color(0xff60D9FF), fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text("Horaire de la journée",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),

                      if ((_planning!['horaire'] as List).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text("Aucune tâche à planifier aujourd'hui.",
                              style: TextStyle(color: Colors.white.withOpacity(.5))),
                        ),

                      ...List.generate((_planning!['horaire'] as List).length, (i) {
                        final bloc = _planning!['horaire'][i];
                        final couleur = _couleurBloc(bloc['type']);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(.08)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: couleur.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(_iconeBloc(bloc['type']), color: couleur, size: 17),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bloc['titre'],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text('${bloc['debut']} → ${bloc['fin']}',
                                        style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    if (_humeurDuJour == null && !_loadingHumeur)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            "Choisissez votre humeur ci-dessus pour générer votre planning du jour.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(.5)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}