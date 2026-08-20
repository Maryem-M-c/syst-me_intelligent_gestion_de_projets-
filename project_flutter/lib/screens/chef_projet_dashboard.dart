import 'package:flutter/material.dart';
import 'projets_screen.dart';
import 'taches_screen.dart';
import 'profil_screen.dart';
import '../services/api_service.dart';

import 'ajouter_projet_screen.dart';
import 'assistant_screen.dart';

import 'demandes_clients_screen.dart';


class ChefProjetDashboard extends StatefulWidget {
  const ChefProjetDashboard({super.key});

  @override
  State<ChefProjetDashboard> createState() => _ChefProjetDashboardState();
}

class _ChefProjetDashboardState extends State<ChefProjetDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
  ProjetsScreen(),
  //TachesScreen(),
  TachesScreen(role: 'chef_projet'),
  AssistantScreen(),
  DemandesClientsScreen(),
  ProfilScreen(),
];

  final List<String> _titles = const ['Projets', 'Tâches', 'Assistant IA','Demandes IA', 'Profil'];

  final List<IconData> _icons = const [
    Icons.folder_rounded,
    Icons.task_alt_rounded,
    Icons.smart_toy_rounded,
    Icons.mark_email_unread_outlined,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E0A16),
      extendBodyBehindAppBar: false,

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icons[_selectedIndex],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                Expanded(
  child: _selectedIndex == 2
      ? const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assistant IA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: .3,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Toujours disponible',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        )
      : _selectedIndex == 3
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Demandes clients (IA)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Générées automatiquement par l'assistant IA",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            )
          : Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: .3,
              ),
            ),
),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amberAccent,
                      ),
                      tooltip: 'Vérifier les retards',
                      onPressed: () async {
                        final result = await ApiService.post('verifier-retards', {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xff1C1230),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            content: Text(
                              result['message'] ?? 'Vérification terminée',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
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
        child: _screens[_selectedIndex],
      ),

      // ================= BOTTOM NAV =================

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff1C1230),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 62,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xff5B2EFF).withOpacity(.25),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? Colors.white : Colors.white38,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? const Color(0xffC084FC) : Colors.white38,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'Projets'),
              NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task_alt_rounded), label: 'Tâches'),
              NavigationDestination(icon: Icon(Icons.smart_toy_outlined),selectedIcon: Icon(Icons.smart_toy_rounded),label: 'Assistant'),
              NavigationDestination(icon: Icon(Icons.mark_email_unread_outlined), label: 'Demandes'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}