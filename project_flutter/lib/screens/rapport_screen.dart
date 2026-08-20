import 'package:flutter/material.dart';
import '../models/rapport.dart';
import '../services/api_service.dart';

class RapportScreen extends StatefulWidget {
  final int projetId;
  final String nomProjet;

  const RapportScreen({super.key, required this.projetId, required this.nomProjet});

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  List<Rapport> _rapports = [];
  bool _loading = true;
  bool _generating = false;

  Map<String, dynamic>? _prediction;
  bool _loadingPrediction = false;

  @override
  void initState() {
    super.initState();
    _loadRapports();
  }

  Future<void> _loadRapports() async {
    setState(() => _loading = true);
    final data = await ApiService.get('projets/${widget.projetId}/rapports');
    setState(() {
      _rapports = (data as List).map((r) => Rapport.fromJson(r)).toList();
      _loading = false;
    });
  }

  Future<void> _genererRapport() async {
    setState(() => _generating = true);
    try {
      await ApiService.post('projets/${widget.projetId}/generer-rapport', {});
      await _loadRapports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff1C1230),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Text(
              'Erreur lors de la génération du rapport',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    setState(() => _generating = false);
  }

  Future<void> _predireDepassement() async {
    setState(() => _loadingPrediction = true);
    try {
      final result = await ApiService.get('projets/${widget.projetId}/predire-depassement');
      setState(() => _prediction = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff1C1230),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Text(
              'Erreur lors de la prédiction',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    setState(() => _loadingPrediction = false);
  }

  Color _couleurRisque(String niveau) {
    switch (niveau) {
      case 'Élevé':
        return const Color(0xffFF5C7A);
      case 'Modéré':
        return const Color(0xffFFB84D);
      case 'Faible':
        return const Color(0xff9C6CFF);
      default:
        return const Color(0xff4ADE80);
    }
  }

  IconData _iconeRisque(String niveau) {
    switch (niveau) {
      case 'Élevé':
        return Icons.warning_amber_rounded;
      case 'Modéré':
        return Icons.timelapse_rounded;
      case 'Faible':
        return Icons.trending_up_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E0A16),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2A1454),
                Color(0xff5B2EFF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x555B2EFF),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
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
                      color: Colors.white.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Rapports",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.nomProjet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.65),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
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
              Color(0xff130C22),
              Color(0xff0E0A16),
            ],
          ),
        ),
        child: Column(
          children: [
            // --------- Bouton Prédiction ML ---------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xff2A1454), Color(0xff3D1F7A)],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _loadingPrediction ? null : _predireDepassement,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _loadingPrediction
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xff9C6CFF)),
                                )
                              : const Icon(Icons.query_stats_rounded, color: Color(0xff9C6CFF), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _loadingPrediction
                                ? 'Analyse en cours...'
                                : 'Prédire le dépassement (Machine Learning)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --------- Carte résultat prédiction ---------
            if (_prediction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _couleurRisque(_prediction!['niveau_risque']).withOpacity(.10),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _couleurRisque(_prediction!['niveau_risque']).withOpacity(.35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _couleurRisque(_prediction!['niveau_risque']).withOpacity(.18),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              _iconeRisque(_prediction!['niveau_risque']),
                              color: _couleurRisque(_prediction!['niveau_risque']),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '📊 Prédiction Machine Learning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: Colors.white.withOpacity(.08)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dépassement estimé',
                              style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 13)),
                          Text(
                            '${_prediction!['depassement_pct']}%',
                            style: TextStyle(
                              color: _couleurRisque(_prediction!['niveau_risque']),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Retard estimé',
                              style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 13)),
                          Text(
                            '${_prediction!['jours_estimes_supplementaires']} jour(s)',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Niveau de risque',
                              style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _couleurRisque(_prediction!['niveau_risque']).withOpacity(.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _prediction!['niveau_risque'],
                              style: TextStyle(
                                color: _couleurRisque(_prediction!['niveau_risque']),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _prediction!['message'],
                        style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withOpacity(.75)),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // --------- Liste des rapports ---------
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xff9C6CFF)),
                    )
                  : RefreshIndicator(
                      color: const Color(0xff9C6CFF),
                      backgroundColor: const Color(0xff1C1230),
                      onRefresh: _loadRapports,
                      child: _rapports.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 60),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.description_outlined,
                                          color: Colors.white.withOpacity(.25), size: 54),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Aucun rapport généré pour ce projet',
                                        style: TextStyle(color: Colors.white.withOpacity(.55)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: _rapports.length,
                              itemBuilder: (context, index) {
                                final rapport = _rapports[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.05),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(.10),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 34,
                                                height: 34,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff9C6CFF).withOpacity(.15),
                                                  borderRadius: BorderRadius.circular(11),
                                                ),
                                                child: const Icon(
                                                  Icons.description_outlined,
                                                  color: Color(0xff9C6CFF),
                                                  size: 17,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text('Période : ${rapport.periode}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Divider(color: Colors.white.withOpacity(.08)),
                                      const SizedBox(height: 10),
                                      Text(
                                        rapport.contenu,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.6,
                                          color: Colors.white.withOpacity(.75),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),

      // ================= FAB =================

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff5B2EFF), Color(0xff9C6CFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(.55),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _generating ? null : _genererRapport,
          icon: _generating
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, color: Colors.white),
          label: Text(
            _generating ? 'Génération...' : 'Générer un rapport',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}