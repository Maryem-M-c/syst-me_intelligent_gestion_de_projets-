import 'package:flutter/material.dart';
import 'package:project_flutter/screens/ajouter_projet_screen.dart';
import '../services/api_service.dart';
import 'ajouter_projet_screen.dart';

class DemandesClientsScreen extends StatefulWidget {
  const DemandesClientsScreen({super.key});

  @override
  State<DemandesClientsScreen> createState() => _DemandesClientsScreenState();
}

class _DemandesClientsScreenState extends State<DemandesClientsScreen> {
  List<dynamic> _demandes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.get('demandes-projets');
    setState(() {
      _demandes = data;
      _loading = false;
    });
  }

  Future<void> _marquerTraitee(int id) async {
    await ApiService.put('demandes-projets/$id/traiter', {});
    _load();
  }

  Future _supprimerDemande(int id) async {
  final confirmation = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xff1C1230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer la demande ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment supprimer cette demande ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  if (confirmation != true) return;

  await ApiService.delete('demandes-projets/$id');

  await _load();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E0A16),

      
        

      // ================= BODY =================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff130C22), Color(0xff0E0A16)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff9C6CFF)))
            : _demandes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, color: Colors.white.withOpacity(.20), size: 54),
                        const SizedBox(height: 14),
                        Text("Aucune demande de projet pour le moment",
                            style: TextStyle(color: Colors.white.withOpacity(.5))),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xff9C6CFF),
                    backgroundColor: const Color(0xff1C1230),
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: _demandes.length,
                      itemBuilder: (context, i) {
                        final d = _demandes[i];
                        final traitee = d['statut'] == 'traitee';
                        final clientNom = d['client']?['name'] ?? '?';
                        final initiale = clientNom.toString().trim().isNotEmpty
                            ? clientNom.toString().trim()[0].toUpperCase()
                            : "?";
                        final couleurStatut = traitee ? const Color(0xff4ADE80) : const Color(0xffFFB84D);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: couleurStatut.withOpacity(.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ================= HEADER =================

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xff5B2EFF), Color(0xff9C6CFF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          initiale,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(d['nom_projet'],
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5)),
                                          const SizedBox(height: 3),
                                          Text('Client : $clientNom',
                                              style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12)),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: couleurStatut.withOpacity(.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: couleurStatut.withOpacity(.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(color: couleurStatut, shape: BoxShape.circle),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            traitee ? 'Traitée' : 'Nouvelle',
                                            style: TextStyle(
                                              color: couleurStatut,
                                              fontSize: 11, fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),

                                const SizedBox(height: 14),

                                // ================= TYPE PROJET =================

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.03),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.category_outlined, size: 15, color: Colors.white.withOpacity(.4)),
                                      const SizedBox(width: 8),
                                      Text('Type : ${d['type_projet']}',
                                          style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 12.5)),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Divider(color: Colors.white.withOpacity(.08)),

                                const SizedBox(height: 12),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 15, color: const Color(0xff9C6CFF).withOpacity(.7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(d['description_generee'] ?? '',
                                          style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 13, height: 1.55)),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Divider(color: Colors.white.withOpacity(.08)),

                                const SizedBox(height: 4),

                                // ================= ACTIONS =================

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    _actionChip(
                                      icon: Icons.delete_outline_rounded,
                                      label: 'Supprimer',
                                      color: Colors.redAccent,
                                      onPressed: () => _supprimerDemande(d['id']),
                                    ),

                                    if (!traitee) ...[
                                      const SizedBox(width: 4),
                                      _actionChip(
                                        icon: Icons.check_circle_outline_rounded,
                                        label: 'Marquer traitée',
                                        color: const Color(0xff4ADE80),
                                        onPressed: () => _marquerTraitee(d['id']),
                                      ),
                                    ],

                                    const SizedBox(width: 4),

                                    _actionChip(
                                      icon: Icons.add_circle_outline_rounded,
                                      label: 'Créer le projet',
                                      color: const Color(0xff9C6CFF),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AjouterProjetScreen(
                                              nomInitial: d['nom_projet'],
                                              descriptionInitial: d['description_generee'],
                                              //clientIdInitial: d['client_id'],
                                              clientNameInitial: d['client']?['name'],
                                              demandeId: d['id'],
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          _load();
                                        }
                                      },
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  // ================= ACTION CHIP =================

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}