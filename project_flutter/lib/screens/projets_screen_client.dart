import 'package:flutter/material.dart';
import '../models/projet.dart';
import '../services/api_service.dart';

import 'creer_projet_client_screen.dart';

class ProjetsScreenClient extends StatefulWidget {
  const ProjetsScreenClient({super.key});

  @override
  State<ProjetsScreenClient> createState() =>
      _ProjetsScreenClientState();
}

class _ProjetsScreenClientState
    extends State<ProjetsScreenClient> {

  List<Projet> projets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    chargerProjets();
  }

  Future<void> chargerProjets() async {
    try {
      final data = await ApiService.get('projets');

      setState(() {
        projets =
            (data as List).map((e) => Projet.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        loading = false;
      });
    }
  }

  Color couleurPriorite(String p) {
    switch (p) {
      case "haute":
        return const Color(0xffF87171);
      case "normale":
        return const Color(0xffFBBF24);
      default:
        return const Color(0xff4ADE80);
    }
  }

  Color couleurStatut(String s) {
    switch (s) {
      case "termine":
        return const Color(0xff4ADE80);
      case "en_cours":
        return const Color(0xff60A5FA);
      case "en_retard":
        return const Color(0xffF87171);
      default:
        return const Color(0xff94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xff0D0710),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xffEC4899)),
        ),
      );
    }

    return Scaffold(

      backgroundColor: const Color(0xff0D0710),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xffEC4899), Color(0xffF43F5E)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffEC4899).withOpacity(.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Créer projet",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreerProjetClientScreen(),
              ),
            );

            if (result == true) {
              chargerProjets();
            }
          },
        ),
      ),

      body: projets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_off_outlined,
                      color: Colors.white.withOpacity(.20), size: 54),
                  const SizedBox(height: 14),
                  Text(
                    "Aucun projet",
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(.5)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(

              color: const Color(0xffEC4899),
              backgroundColor: const Color(0xff1B0F22),
              onRefresh: chargerProjets,

              child: ListView.builder(

                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

                itemCount: projets.length,

                itemBuilder: (context, index) {

                  final projet = projets[index];

                  return Container(

                    margin: const EdgeInsets.only(bottom: 16),

                    decoration: BoxDecoration(
                      color: const Color(0xff17091C),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(.06)),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(18),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Row(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Expanded(

                                child: Text(

                                  projet.nom,

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),

                                ),

                              ),

                              Container(

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: couleurPriorite(
                                          projet.priorite)
                                      .withOpacity(.15),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: couleurPriorite(projet.priorite).withOpacity(.4),
                                  ),
                                ),

                                child: Text(

                                  projet.priorite,

                                  style: TextStyle(
                                    color: couleurPriorite(
                                        projet.priorite),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),

                                ),

                              )

                            ],

                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 16, color: Colors.white.withOpacity(.45)),
                              const SizedBox(width: 8),
                              Text(projet.client,
                                  style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 13.5)),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 14, color: Colors.white.withOpacity(.45)),
                              const SizedBox(width: 8),
                              Text(
                                  "${projet.dateDebut}  →  ${projet.dateFin}",
                                  style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12.5)),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: couleurStatut(projet.statut).withOpacity(.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: couleurStatut(projet.statut).withOpacity(.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: couleurStatut(projet.statut),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  projet.statut.replaceAll("_", " "),
                                  style: TextStyle(
                                    color: couleurStatut(projet.statut),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          Divider(color: Colors.white.withOpacity(.06)),

                          const SizedBox(height: 4),

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment.end,

                            children: [

                              GestureDetector(

                                onTap: () async {

                                  bool? ok =
                                      await showDialog<bool>(

                                    context: context,

                                    builder: (_) => AlertDialog(

                                      backgroundColor: const Color(0xff17091C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      title: const Text(
                                          "Supprimer",
                                          style: TextStyle(color: Colors.white)),

                                      content: const Text(
                                          "Voulez-vous supprimer ce projet ?",
                                          style: TextStyle(color: Colors.white60)),

                                      actions: [

                                        TextButton(

                                          onPressed: () {
                                            Navigator.pop(
                                                context,
                                                false);
                                          },

                                          child: Text(
                                              "Annuler",
                                              style: TextStyle(color: Colors.white.withOpacity(.55))),

                                        ),

                                        TextButton(

                                          onPressed: () {
                                            Navigator.pop(
                                                context,
                                                true);
                                          },

                                          child: const Text(
                                              "Supprimer",
                                              style: TextStyle(color: Color(0xffF87171), fontWeight: FontWeight.bold)),

                                        ),

                                      ],

                                    ),

                                  );

                                  if (ok == true) {

                                    await ApiService.deleteProjet(
                                        projet.id);

                                    chargerProjets();

                                  }

                                },

                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF87171).withOpacity(.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xffF87171).withOpacity(.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 17, color: Color(0xffF87171)),
                                      SizedBox(width: 8),
                                      Text(
                                        "Supprimer",
                                        style: TextStyle(color: Color(0xffF87171), fontWeight: FontWeight.w600, fontSize: 13.5),
                                      ),
                                    ],
                                  ),
                                ),

                              ),

                            ],

                          )

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),

    );

  }
}