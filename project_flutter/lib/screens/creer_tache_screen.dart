import 'package:flutter/material.dart';
import '../models/projet.dart';
import '../services/api_service.dart';

class CreerTacheScreen extends StatefulWidget {
  const CreerTacheScreen({super.key});

  @override
  State<CreerTacheScreen> createState() => _CreerTacheScreenState();
}

class _CreerTacheScreenState extends State<CreerTacheScreen> {
  final _titreController = TextEditingController();
  final _competencesController = TextEditingController();
  final _echeanceController = TextEditingController();

  List<Projet> _projets = [];
  int? _projetId;

  bool _loading = false;
  Map<String, dynamic>? _suggestionIA;
  int? _tacheId; // tâche créée en attente d'attribution

  @override
  void initState() {
    super.initState();
    _loadProjets();
  }

  Future<void> _loadProjets() async {
    final data = await ApiService.get('projets');
    setState(() {
      _projets = (data as List).map((p) => Projet.fromJson(p)).toList();
    });
  }

  Future<void> _creerTache() async {
    if (_projetId == null || _titreController.text.isEmpty || _echeanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff2D2A26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'Merci de remplir tous les champs obligatoires',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final competences = _competencesController.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final result = await ApiService.post('taches', {
      'projet_id': _projetId,
      'titre': _titreController.text,
      'competences_requises': competences,
      'echeance': _echeanceController.text,
    });
    
    print(result);
    
    setState(() {
      _loading = false;
      _tacheId = result['tache']['id'];
      _suggestionIA = result['suggestion_ia'];
    });
  }

  Future<void> _attribuerEmploye() async {
  if (_tacheId == null || _suggestionIA == null) return;

  setState(() => _loading = true);

  final result = await ApiService.put(
    'taches/$_tacheId',
    {
      'employe_id': _suggestionIA!['employe_id'],
    },
  );

  print(result);

  setState(() => _loading = false);

  if (mounted) {
    Navigator.pop(context, true);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xffFBF6F0),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xffFBF6F0),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xff2D2A26), size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Nouvelle tâche",
                    style: TextStyle(
                      color: Color(0xff2D2A26),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [

            // ================= HERO BANNER =================

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 27, 25, 24),
                    Color.fromARGB(255, 179, 35, 219),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 179, 35, 219).withOpacity(.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.playlist_add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Assignez une nouvelle tâche à un projet et laissez l'IA suggérer le meilleur employé.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Text(
              "DÉTAILS DE LA TÂCHE",
              style: TextStyle(
                color: const Color(0xff2D2A26).withOpacity(.4),
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 14),

            // ================= CARD =================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [

                  _buildDropdown(),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _titreController,
                    hint: "Titre de la tâche",
                    icon: Icons.task_alt_rounded,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _competencesController,
                    hint: "Compétences requises",
                    icon: Icons.psychology_outlined,
                    subHint: "ex: Laravel, PHP",
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _echeanceController,
                    hint: "Échéance",
                    icon: Icons.event_outlined,
                    subHint: "AAAA-MM-JJ  •  ex: 2026-07-20",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 28),

            if (_suggestionIA == null)
              GestureDetector(
                onTap: _loading ? null : _creerTache,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 179, 35, 219),
                        Color.fromARGB(255, 31, 28, 26),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 197, 45, 224).withOpacity(.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Créer la tâche",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

            if (_suggestionIA != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffFFD8B8), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xffFFF0E4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color.fromARGB(255, 179, 35, 219),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Suggestion IA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                            color: Color(0xff2D2A26),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _suggestionRow(
                      icon: Icons.person_outline_rounded,
                      label: "Employé recommandé",
                      value: _suggestionIA!['nom'] ?? "Aucun",
                    ),
                    if (_suggestionIA!['score'] != null) ...[
                      const SizedBox(height: 12),
                      _suggestionRow(
                        icon: Icons.speed_rounded,
                        label: "Score de compatibilité",
                        value: "${_suggestionIA!['score']}",
                      ),
                    ],
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: _loading ? null : _attribuerEmploye,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: const Color(0xff2D2A26),
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Attribuer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }

  // ================= REUSABLE FIELD =================

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? subHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xffFFF0E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 179, 35, 219), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xff2D2A26), fontSize: 15, fontWeight: FontWeight.w600),
            cursorColor: const Color(0xffFF8A65),
            decoration: InputDecoration(
              labelText: hint,
              labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
              hintText: subHint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xffFFF0E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.folder_special_outlined, color:Color.fromARGB(255, 179, 35, 219), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _projetId,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color.fromARGB(255, 179, 35, 219)),
              style: const TextStyle(color: Color(0xff2D2A26), fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Projet',
                labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              items: _projets
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom)))
                  .toList(),
              onChanged: (val) => setState(() => _projetId = val),
            ),
          ),
        ),
      ],
    );
  }

  // ================= SUGGESTION ROW =================

  Widget _suggestionRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          "$label : ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xff2D2A26), fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}