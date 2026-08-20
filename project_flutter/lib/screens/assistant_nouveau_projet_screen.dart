import 'package:flutter/material.dart';
import '../services/api_service.dart';



class AssistantNouveauProjetScreen extends StatefulWidget {
  const AssistantNouveauProjetScreen({super.key});

  @override
  State<AssistantNouveauProjetScreen> createState() => _AssistantNouveauProjetScreenState();
}

class _AssistantNouveauProjetScreenState extends State<AssistantNouveauProjetScreen> {
  int _etape = 0; // 0: infos de base, 1: questions, 2: description finale

  final _nomController = TextEditingController();
  String _typeProjet = 'application mobile';

  final List<String> _typesProjet = const [
    'application mobile',
    'e-commerce',
    'pharmacie',
    'restaurant',
    'site vitrine',
    'autre',
  ];

  List<String> _questions = [];
  final Map<int, TextEditingController> _reponsesControllers = {};

  bool _loading = false;
  String? _descriptionFinale;
  

  Future<void> _analyserAvecIA() async {
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff17091C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text('Merci de donner un nom à votre projet', style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ApiService.post('demandes-projets/generer-questions', {
        'nom_projet': _nomController.text.trim(),
        'type_projet': _typeProjet,
      });

      final questions = List<String>.from(result['questions']);
      setState(() {
        _questions = questions;
        _reponsesControllers.clear();
        for (int i = 0; i < questions.length; i++) {
          _reponsesControllers[i] = TextEditingController();
        }
        _etape = 1;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff17091C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Text("Erreur lors de l'analyse IA, réessayez.", style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

Future<void> _genererDescription() async {
    final reponses = <Map<String, String>>[];
    for (int i = 0; i < _questions.length; i++) {
      final texte = _reponsesControllers[i]?.text.trim() ?? '';
      reponses.add({'question': _questions[i], 'reponse': texte.isEmpty ? 'Non précisé' : texte});
    }

    setState(() => _loading = true);
    try {
      final result = await ApiService.post('demandes-projets/envoyer', {
        'nom_projet': _nomController.text.trim(),
        'type_projet': _typeProjet,
        'reponses': reponses,
      });

      print('RÉSULTAT REÇU : $result'); // ← debug temporaire

      final description = result['description_generee'];

      if (description == null) {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xff17091C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              content: Text('Réponse inattendue du serveur : $result', style: const TextStyle(color: Colors.white)),
            ),
          );
        }
        return;
      }

      setState(() {
        _descriptionFinale = description;
        _etape = 2;
        _loading = false;
      });
    } catch (e) {
      print('ERREUR : $e'); // ← debug temporaire
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff17091C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Text('Erreur : $e', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }
  

  

  void _recommencer() {
    setState(() {
      _etape = 0;
      _nomController.clear();
      _questions = [];
      _reponsesControllers.clear();
      _descriptionFinale = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D0710),

    

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff17091C), Color(0xff0D0710)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // --------- Indicateur d'étapes ---------
            Row(
              children: List.generate(3, (i) {
                final actif = i <= _etape;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: actif ? const Color(0xffEC4899) : Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // --------- Étape 0 : infos de base ---------
            if (_etape == 0) ...[
              _carte(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Parlez-nous de votre projet",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _champTexte(_nomController, "Nom du projet", "ex: Boutique en ligne de vêtements"),
                    const SizedBox(height: 14),
                    const Text("Type de projet", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _typesProjet.map((t) {
                        final selectionne = _typeProjet == t;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => _typeProjet = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectionne ? const Color(0xffEC4899).withOpacity(.20) : Colors.white.withOpacity(.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectionne ? const Color(0xffEC4899) : Colors.white.withOpacity(.10),
                              ),
                            ),
                            child: Text(t,
                                style: TextStyle(
                                  color: selectionne ? const Color(0xffEC4899) : Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _boutonPrincipal(
                texte: 'Analyser avec l\'IA',
                icone: Icons.auto_awesome,
                onPressed: _loading ? null : _analyserAvecIA,
                chargement: _loading,
              ),
            ],

            // --------- Étape 1 : questions générées ---------
            if (_etape == 1) ...[
              _carte(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.psychology_outlined, color: Color(0xffEC4899), size: 20),
                        SizedBox(width: 8),
                        Text("Quelques précisions",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "L'IA a généré ces questions pour mieux comprendre votre besoin.",
                      style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(_questions.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _carte(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_questions[i],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                        const SizedBox(height: 10),
                        _champTexte(_reponsesControllers[i]!, null, "Votre réponse...", lignes: 2),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              _boutonPrincipal(
                texte: 'Générer la description',
                icone: Icons.description_outlined,
                onPressed: _loading ? null : _genererDescription,
                chargement: _loading,
              ),
            ],

            // --------- Étape 2 : description finale ---------
            if (_etape == 2 && _descriptionFinale != null) ...[
              _carte(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle_outline, color: Color(0xff4ADE80), size: 20),
                        SizedBox(width: 8),
                        Text("Description envoyée au chef de projet",
                            style: TextStyle(color: Color(0xff4ADE80), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(.08)),
                    const SizedBox(height: 12),
                    Text(
                      _descriptionFinale!,
                      style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13.5, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _boutonPrincipal(
                texte: 'Créer une nouvelle demande',
                icone: Icons.add,
                onPressed: _recommencer,
                chargement: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _carte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff17091C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08), width: 1.2),
      ),
      child: child,
    );
  }

  Widget _champTexte(TextEditingController controller, String? label, String hint, {int lignes = 1}) {
    return TextField(
      controller: controller,
      maxLines: lignes,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      cursorColor: const Color(0xffEC4899),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(.30)),
        filled: true,
        fillColor: Colors.white.withOpacity(.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEC4899)),
        ),
      ),
    );
  }

  Widget _boutonPrincipal({
    required String texte,
    required IconData icone,
    required VoidCallback? onPressed,
    required bool chargement,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xffEC4899), Color(0xffF43F5E)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffEC4899).withOpacity(.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                chargement
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(icone, color: Colors.white, size: 19),
                const SizedBox(width: 10),
                Text(texte, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}