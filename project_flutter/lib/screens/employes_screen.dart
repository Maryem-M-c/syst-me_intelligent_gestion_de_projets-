import 'package:flutter/material.dart';
import '../models/employe.dart';
import '../services/api_service.dart';
import 'creer_employe_screen.dart';
import 'modifier_employe_screen.dart';

class EmployesScreen extends StatefulWidget {
  const EmployesScreen({super.key});

  @override
  State<EmployesScreen> createState() => _EmployesScreenState();
}

class _EmployesScreenState extends State<EmployesScreen> {
  List<Employe> _employes = [];
  bool _loading = true;

  // palette d'avatars vive, cycle en fonction de l'index
  final List<List<Color>> _avatarGradients = const [
    [Color(0xff6366F1), Color(0xff8B5CF6)],
    [Color(0xffEC4899), Color(0xffF472B6)],
    [Color(0xff06B6D4), Color(0xff22D3EE)],
    [Color(0xffF59E0B), Color(0xffFBBF24)],
    [Color(0xff10B981), Color(0xff34D399)],
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.get('employes');
    setState(() {
      _employes = (data as List).map((e) => Employe.fromJson(e)).toList();
      _loading = false;
    });
  }

  Color _couleurCharge(int charge) {
    if (charge >= 4) return const Color(0xffEF4444);
    if (charge >= 2) return const Color(0xffF59E0B);
    return const Color(0xff10B981);
  }

  Future<void> _confirmerSuppression(Employe employe) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Supprimer la fiche employé', style: TextStyle(color: Color(0xff1E1B2E))),
        content: Text(
          'Voulez-vous vraiment supprimer la fiche de "${employe.nom}" ?',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: Colors.grey.shade500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Color(0xffEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await ApiService.delete('employes/${employe.id}');
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff1E1B2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Text('Fiche employé supprimée', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 131, 119, 147),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff8B5CF6)))
          : _employes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          color: Colors.grey.shade300, size: 60),
                      const SizedBox(height: 14),
                      Text(
                        'Aucun employé enregistré',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xff8B5CF6),
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: _employes.length,
                    itemBuilder: (context, i) {
                      final e = _employes[i];
                      final couleur = _couleurCharge(e.chargeActuelle);
                      final gradient = _avatarGradients[i % _avatarGradients.length];
                      final initiale = e.nom.trim().isNotEmpty ? e.nom.trim()[0].toUpperCase() : "?";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: gradient[0].withOpacity(.10),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradient[0].withOpacity(.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initiale,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff1E1B2E),
                                          fontSize: 16.5,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < e.niveau ? Icons.star_rounded : Icons.star_outline_rounded,
                                            size: 14,
                                            color: const Color(0xffF59E0B),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: couleur.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${e.chargeActuelle} tâche(s)',
                                        style: TextStyle(
                                          color: couleur,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: gradient[0].withOpacity(.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.psychology_outlined, size: 15, color: gradient[0]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.competences,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Divider(color: Colors.grey.shade100),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _actionButton(
                                    icon: Icons.edit_outlined,
                                    label: 'Modifier',
                                    color: const Color(0xff6366F1),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ModifierEmployeScreen(employe: e)),
                                      );
                                      if (result == true) _load();
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _actionButton(
                                    icon: Icons.delete_outline_rounded,
                                    label: 'Supprimer',
                                    color: const Color(0xffEF4444),
                                    onPressed: () => _confirmerSuppression(e),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff6366F1), Color(0xff8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8B5CF6).withOpacity(.45),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          label: const Text(
            "Nouvel employé",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreerEmployeScreen()),
            );
            if (result == true) _load();
          },
        ),
      ),
    );
  }

  // ================= ACTION BUTTON =================

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}