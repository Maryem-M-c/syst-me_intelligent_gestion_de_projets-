import 'package:flutter/material.dart';
import '../models/tache.dart';
import '../services/api_service.dart';
import 'creer_tache_screen.dart';
import 'modifier_tache_screen.dart';

class TachesScreen extends StatefulWidget {
  final String role;
  const TachesScreen({super.key, required this.role});

  @override
  State<TachesScreen> createState() => _TachesScreenState();
}

class _TachesScreenState extends State<TachesScreen> {
  List<Tache> _taches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTaches();
  }

  Future<void> _loadTaches() async {
    setState(() => _loading = true);
    final data = await ApiService.get('taches');
    setState(() {
      _taches = (data as List).map((t) => Tache.fromJson(t)).toList();
      _loading = false;
    });
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

  Future<void> _confirmerSuppression(Tache tache) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff102030),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Supprimer la tâche', style: TextStyle(color: Colors.white)),
        content: Text(
          'Voulez-vous vraiment supprimer "${tache.titre}" ?',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: Colors.white.withOpacity(.55))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Color(0xffFB7185), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await ApiService.delete('taches/${tache.id}');
      _loadTaches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff102030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Text('Tâche supprimée', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final bool peutGerer =
       widget.role == 'chef_projet' ||
       widget.role == 'admin';

    final int enCours = _taches.where((t) => t.statut == 'en_cours').length;
    final int terminees = _taches.where((t) => t.statut == 'terminee').length;
    final int enRetard = _taches.where((t) => t.statut == 'en_retard').length;

    return Scaffold(

      backgroundColor: const Color(0xff081019),

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
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff38BDF8)))
            : Column(
                children: [

                  // ================= STATS STRIP =================

                  if (!_loading)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              label: "En cours",
                              value: enCours,
                              color: const Color(0xff38BDF8),
                              icon: Icons.autorenew_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              label: "Terminées",
                              value: terminees,
                              color: const Color(0xff34D399),
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              label: "En retard",
                              value: enRetard,
                              color: const Color(0xffFB7185),
                              icon: Icons.error_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: _taches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.checklist_rtl_rounded,
                                  color: Colors.white.withOpacity(.20), size: 54),
                              const SizedBox(height: 14),
                              Text(
                                'Aucune tâche pour le moment',
                                style: TextStyle(color: Colors.white.withOpacity(.5)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xff38BDF8),
                          backgroundColor: const Color(0xff102030),
                          onRefresh: _loadTaches,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: _taches.length,
                            itemBuilder: (context, index) {
                              final tache = _taches[index];
                              final couleur = _statutColor(tache.statut);
                              final initiale = (tache.employeNom?.trim().isNotEmpty ?? false)
                                  ? tache.employeNom!.trim()[0].toUpperCase()
                                  : "?";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xff0F1E2E),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withOpacity(.06)),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [

                                      // ================= ACCENT STRIPE =================

                                      Container(
                                        width: 5,
                                        decoration: BoxDecoration(
                                          color: couleur,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  // avatar
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: tache.employeNom != null
                                                          ? couleur.withOpacity(.18)
                                                          : Colors.white.withOpacity(.06),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        initiale,
                                                        style: TextStyle(
                                                          color: tache.employeNom != null
                                                              ? couleur
                                                              : Colors.white38,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 12),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          tache.titre,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 15.5,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 3),
                                                        Text(
                                                          tache.employeNom ?? 'Non assigné',
                                                          style: TextStyle(
                                                            fontSize: 12.5,
                                                            color: tache.employeNom != null
                                                                ? Colors.white.withOpacity(.5)
                                                                : const Color(0xffFBBF24),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: couleur.withOpacity(.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      tache.statut.replaceAll('_', ' '),
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        color: couleur,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),

                                              const SizedBox(height: 12),

                                              Row(
                                                children: [
                                                  Icon(Icons.event_outlined, size: 13, color: Colors.white.withOpacity(.35)),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Échéance : ${tache.echeance}',
                                                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.4)),
                                                  ),
                                                  const Spacer(),

  if (peutGerer) ...[
      _iconAction(
        icon: Icons.edit_outlined,
        color: const Color(0xffFBBF24),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModifierTacheScreen(
                tache: tache,
              ),
            ),
          );

          if (result == true) {
            _loadTaches();
          }
        },
      ),

      const SizedBox(width: 4),

      _iconAction(
        icon: Icons.delete_outline_rounded,
        color: const Color(0xffFB7185),
        onPressed: () =>
            _confirmerSuppression(tache),
      ),
    ],

    if (widget.role == 'employe' &&
        tache.statut != 'terminee')
      _iconAction(
        icon: Icons.sync_rounded,
        color: const Color(0xff38BDF8),
        onPressed: () async {
          final nouveauStatut =
              await showDialog<String>(
            context: context,
            builder: (context) => SimpleDialog(
              backgroundColor: const Color(0xff102030),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Changer le statut',
                style: TextStyle(color: Colors.white),
              ),
              children: [
                'a_faire',
                'en_cours',
                'en_revision',
                'terminee',
              ].map((statut) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      statut,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statutColor(statut),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        statut.replaceAll(
                          '_',
                          ' ',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );

          if (nouveauStatut != null &&
              nouveauStatut != tache.statut) {
            await ApiService.put(
              'taches/${tache.id}',
              {
                'statut': nouveauStatut,
              },
            );

            _loadTaches();
          }
        },
      ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                ],
              ),
        ),
      ),

      floatingActionButton: peutGerer
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xff38BDF8),
              elevation: 6,
              icon: const Icon(Icons.add, color: Color(0xff081019)),
              label: const Text(
                "Nouvelle tâche",
                style: TextStyle(color: Color(0xff081019), fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreerTacheScreen(),
                  ),
                );

                if (result == true) {
                  _loadTaches();
                }
              },
            )
          : null,
    );
  }

  // ================= STAT CARD =================

  Widget _statCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xff0F1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  // ================= ICON ACTION =================

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
  
}