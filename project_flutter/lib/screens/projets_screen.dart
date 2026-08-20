import 'package:flutter/material.dart';
import '../models/projet.dart';
import '../services/api_service.dart';

import 'detail_projet_screen.dart';
import 'rapport_screen.dart';
import 'modifier_projet_screen.dart';

import 'ajouter_projet_screen.dart';

class ProjetsScreen extends StatefulWidget {
  const ProjetsScreen({super.key});

  @override
  State<ProjetsScreen> createState() => _ProjetsScreenState();
}

class _ProjetsScreenState extends State<ProjetsScreen> {
  List<Projet> _projets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjets();
  }

  Future<void> _loadProjets() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final data = await ApiService.get('projets');

    print("========== API PROJETS ==========");
    print(data);

    setState(() {
      _projets = (data as List)
          .map((p) => Projet.fromJson(p))
          .toList();

      _loading = false;
    });
  } catch (e) {
    print(e);

    setState(() {
      _error = 'Erreur de chargement des projets';
      _loading = false;
    });
  }
}

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':
        return const Color(0xff5B8DEF);
      case 'termine':
        return const Color(0xff4ADE80);
      case 'en_retard':
        return const Color(0xffF87171);
      default:
        return Colors.grey;
    }
  }

  Color _prioriteColor(String priorite) {
    switch (priorite) {
      case 'haute':
        return const Color(0xffF87171);
      case 'normale':
        return const Color(0xffFBBF24);
      default:
        return const Color(0xff4ADE80);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Container(
        color: const Color(0xff0E0A16),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xff9C6CFF)),
        ),
      );
    }
    if (_error != null) {
      return Container(
        color: const Color(0xff0E0A16),
        child: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    if (_projets.isEmpty) {
      return Container(
        color: const Color(0xff0E0A16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_off_outlined,
                  color: Colors.white.withOpacity(.25), size: 54),
              const SizedBox(height: 14),
              Text(
                'Aucun projet pour le moment',
                style: TextStyle(color: Colors.white.withOpacity(.55)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(

  backgroundColor: const Color(0xff0E0A16),

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

      icon: const Icon(Icons.add, color: Colors.white),

      label: const Text("Ajouter Projet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

      backgroundColor: Colors.transparent,
      elevation: 0,


      onPressed: () async {


        final result = await Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => const AjouterProjetScreen(),

          ),

        );


        if(result == true){

          _loadProjets();

        }


      },

    ),
  ),


  body: RefreshIndicator(
    color: const Color(0xff9C6CFF),
    backgroundColor: const Color(0xff1C1230),
    onRefresh: _loadProjets,
    child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _projets.length,
        itemBuilder: (context, index) {
          final projet = _projets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(.10),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(projet.nom,
                            style: const TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _prioriteColor(projet.priorite).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _prioriteColor(projet.priorite).withOpacity(.4),
                          ),
                        ),
                        child: Text(
                          projet.priorite,
                          style: TextStyle(
                            color: _prioriteColor(projet.priorite),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 15, color: Colors.white.withOpacity(.45)),
                      const SizedBox(width: 6),
                      Text('Client : ${projet.client}',
                          style: TextStyle(color: Colors.white.withOpacity(.60), fontSize: 13.5)),
                    ],
                  ),
                  const SizedBox(height: 10),

if (projet.description != null &&
    projet.description!.trim().isNotEmpty)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.04),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      projet.description!,
      maxLines: 9,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white.withOpacity(.75),
        fontSize: 13,
        height: 1.4,
      ),
    ),
  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white.withOpacity(.45)),
                      const SizedBox(width: 6),
                      Text('${projet.dateDebut} → ${projet.dateFin}',
                          style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statutColor(projet.statut).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statutColor(projet.statut).withOpacity(.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _statutColor(projet.statut),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          projet.statut.replaceAll('_', ' '),
                          style: TextStyle(
                            color: _statutColor(projet.statut),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

Divider(color: Colors.white.withOpacity(.08)),

const SizedBox(height: 4),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [

    // Bouton Rapport IA
    _actionButton(
      icon: Icons.description_outlined,
      label: 'Rapport IA',
      color: const Color(0xff5B8DEF),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RapportScreen(
              projetId: projet.id,
              nomProjet: projet.nom,
            ),
          ),
        );
      },
    ),


    // Bouton Détails
    _actionButton(
      icon: Icons.visibility_outlined,
      label: 'Détails',
      color: const Color(0xff4ADE80),
      onPressed: () {
         Navigator.push(
    context,

    MaterialPageRoute(
      builder: (_) => DetailProjetScreen(
        projet: projet,
      ),
    ),
  );

},
    ),


    // Bouton Modifier
    _actionButton(
      icon: Icons.edit_outlined,
      label: 'Modifier',
      color: const Color(0xffFBBF24),
      onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ModifierProjetScreen(
        projet: projet,
      ),
    ),
  );

  _loadProjets();
},

    ),


    // Bouton Supprimer
    _actionButton(
      icon: Icons.delete_outline_rounded,
      label: 'Supprimer',
      color: const Color(0xffF87171),
      onPressed: () async {


bool? confirmer = await showDialog<bool>(

context: context,

builder: (context)=>AlertDialog(

backgroundColor: const Color(0xff1C1230),

shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
),

title: const Text("Supprimer projet",
    style: TextStyle(color: Colors.white)),

content: const Text(
"Voulez-vous supprimer ce projet ?",
style: TextStyle(color: Colors.white70),
),


actions:[


TextButton(

onPressed: (){
Navigator.pop(context,false);
},

child: Text("Annuler",
    style: TextStyle(color: Colors.white.withOpacity(.6))),

),



TextButton(

onPressed: (){
Navigator.pop(context,true);
},

child: const Text("Supprimer",
    style: TextStyle(color: Color(0xffF87171), fontWeight: FontWeight.bold)),

),


],

)

);



if(confirmer == true){


await ApiService.deleteProjet(projet.id);



_loadProjets();



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
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

}