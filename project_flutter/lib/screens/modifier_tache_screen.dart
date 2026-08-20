import 'package:flutter/material.dart';
import '../models/tache.dart';
import '../services/api_service.dart';

class ModifierTacheScreen extends StatefulWidget {
  final Tache tache;
  const ModifierTacheScreen({super.key, required this.tache});

  @override
  State<ModifierTacheScreen> createState() => _ModifierTacheScreenState();
}

class _ModifierTacheScreenState extends State<ModifierTacheScreen> {
  late TextEditingController _titreController;
  late TextEditingController _echeanceController;
  late String _statut;
  bool _loading = false;

  final List<String> _statuts = ['a_faire', 'en_cours', 'en_revision', 'terminee', 'en_retard'];

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.tache.titre);
    _echeanceController = TextEditingController(text: widget.tache.echeance);
    _statut = widget.tache.statut;
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':
        return const Color(0xff38BDF8);
      case 'terminee':
        return const Color(0xff34D399);
      case 'en_retard':
        return const Color(0xffFB7185);
      case 'en_revision':
        return const Color(0xffFBBF24);
      default:
        return const Color(0xff94A3B8);
    }
  }

  Future<void> _modifier() async {
    setState(() => _loading = true);

    await ApiService.put('taches/${widget.tache.id}', {
      'titre': _titreController.text,
      'echeance': _echeanceController.text,
      'statut': _statut,
    });

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xff081019),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xff0B1B2B),
            border: Border(
              bottom: BorderSide(color: Color(0xff17324A), width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xff38BDF8).withOpacity(.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xff38BDF8).withOpacity(.35)),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xff38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Modifier la tâche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff0B1B2B),
              Color(0xff081019),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [

              Text(
                "Détails de la tâche",
                style: TextStyle(
                  color: Colors.white.withOpacity(.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .5,
                ),
              ),

              const SizedBox(height: 18),

              // ================= CARD =================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xff0F1E2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(.07),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [

                    _buildField(
                      controller: _titreController,
                      hint: "Titre",
                      icon: Icons.task_alt_rounded,
                    ),

                    const SizedBox(height: 18),

                    _buildField(
                      controller: _echeanceController,
                      hint: "Échéance (AAAA-MM-JJ)",
                      icon: Icons.event_outlined,
                      subHint: "2026-07-20",
                    ),

                    const SizedBox(height: 18),

                    _buildDropdown(),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= SAVE BUTTON =================

              GestureDetector(
                onTap: _loading ? null : _modifier,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xff38BDF8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff38BDF8).withOpacity(.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xff081019),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, color: Color(0xff081019), size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Enregistrer les modifications",
                                style: TextStyle(
                                  color: Color(0xff081019),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff081019),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color(0xff38BDF8),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 13),
          hintText: subHint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(.22)),
          prefixIcon: Icon(icon, color: const Color(0xff38BDF8), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xff081019),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _statut,
          dropdownColor: const Color(0xff102030),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff38BDF8)),
          style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Statut',
            labelStyle: TextStyle(color: Colors.white.withOpacity(.4)),
            prefixIcon: const Icon(Icons.push_pin_outlined, color: Color(0xff38BDF8), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          items: _statuts
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _statutColor(s),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(s.replaceAll('_', ' ')),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _statut = val!),
        ),
      ),
    );
  }
}