import 'package:flutter/material.dart';
import 'taches_screen.dart';
import 'profil_screen.dart';
import 'planning_ia_screen.dart';

class EmployeDashboard extends StatefulWidget {
  const EmployeDashboard({super.key});

  @override
  State<EmployeDashboard> createState() => _EmployeDashboardState();
}

class _EmployeDashboardState extends State<EmployeDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TachesScreen(role: 'employe'),
    PlanningIaScreen(),
    ProfilScreen(),
  ];

  final List<String> _titles = const ['Mes tâches', 'Planning IA', 'Profil'];

  final List<IconData> _icons = const [
    Icons.task_alt_rounded,
    Icons.wb_sunny_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xff1A1208),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff4A2E0A),
                Color(0xffF59E0B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x55F59E0B),
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
                      color: Colors.white.withOpacity(.16),
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
  child: _selectedIndex == 1
      ? const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mon planning IA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: .3,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Humeur + organisation de la journée',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
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
              Color(0xff231907),
              Color(0xff1A1208),
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
          color: const Color(0xff2A200C),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(.07)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffF59E0B).withOpacity(.20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 62,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xffF59E0B).withOpacity(.22),
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
                color: selected ? const Color(0xffFBBF24) : Colors.white38,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task_alt_rounded), label: 'Mes tâches'),
              NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny_rounded), label: 'Planning IA'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}