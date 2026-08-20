import 'package:flutter/material.dart';
import '../models/projet.dart';
import 'rapport_screen.dart';


class DetailProjetScreen extends StatelessWidget {

  final Projet projet;

  const DetailProjetScreen({
    super.key,
    required this.projet,
  });


  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':
        return const Color(0xff5B8DEF);
      case 'termine':
        return const Color(0xff4ADE80);
      case 'en_retard':
        return const Color(0xffF87171);
      default:
        return const Color(0xffFBBF24);
    }
  }


  Color _prioriteColor(String priorite) {
    switch(priorite){
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
                  Expanded(
                    child: Text(
                      projet.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Stack(
        children: [

          Container(
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
          ),

          Positioned(
            top: -140,
            right: -110,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(.30),
                    blurRadius: 160,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [


                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff5B2EFF),
                            Color(0xff9C6CFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(.5),
                            blurRadius: 34,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ),


                  const SizedBox(height: 24),


                  Center(
                    child: Text(
                      projet.nom,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),


                  const SizedBox(height: 17),


                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(.10),
                        width: 1.2,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [


                        _infoRow(
                          icon: Icons.apartment_rounded,
                          label: "Client",
                          value: projet.client,
                        ),


                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(.08)),
                        const SizedBox(height: 16),


                        _infoRow(
                          icon: Icons.calendar_today_rounded,
                          label: "Date",
                          value: "${projet.dateDebut} → ${projet.dateFin}",
                        ),


                        const SizedBox(height: 20),
                        Divider(color: Colors.white.withOpacity(.08)),
                        const SizedBox(height: 20),


                        Row(
                          children: [

                            Icon(Icons.star_rounded, size: 18, color: Colors.white.withOpacity(.45)),
                            const SizedBox(width: 10),
                            Text("Priorité",
                                style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 13.5)),
                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _prioriteColor(projet.priorite).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _prioriteColor(projet.priorite).withOpacity(.4),
                                ),
                              ),
                              child: Text(
                                projet.priorite,
                                style: TextStyle(
                                  color: _prioriteColor(projet.priorite),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          ],
                        ),


                        const SizedBox(height: 10),


                        Row(
                          children: [

                            Icon(Icons.push_pin_rounded, size: 18, color: Colors.white.withOpacity(.45)),
                            const SizedBox(width: 10),
                            Text("Statut",
                                style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 13.5)),
                            const Spacer(),

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

                          ],
                        ),


                      ],
                    ),
                  ),



                  const Spacer(),



                  GestureDetector(
                    onTap: () {

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
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff5B2EFF),
                            Color(0xff9C6CFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(.55),
                            blurRadius: 30,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Voir Rapport IA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 10),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO ROW =================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xff9C6CFF).withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 17, color: const Color(0xff9C6CFF)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12.5),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}