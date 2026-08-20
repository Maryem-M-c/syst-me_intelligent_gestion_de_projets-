import 'package:flutter/material.dart';
import 'projets_screen.dart';
import 'taches_screen.dart';
import 'employes_screen.dart';
import 'profil_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    ProjetsScreen(),
    TachesScreen(role: 'admin'),
    EmployesScreen(),
    ProfilScreen(),
  ];

  final List<String> _titles = const ['Projets', 'Tâches', 'Employés', 'Profil'];

  final List<IconData> _icons = const [
    Icons.folder_rounded,
    Icons.task_alt_rounded,
    Icons.groups_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,

      backgroundColor: const Color(0xff121212),

      // ================= DRAWER =================

      drawer: Drawer(
        backgroundColor: const Color(0xff181818),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color.fromARGB(255, 103, 49, 154), Color.fromARGB(255, 183, 159, 214)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Espace Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  "NAVIGATION",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.35),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              for (int i = 0; i < _titles.length; i++)
                _drawerItem(
                  icon: _icons[i],
                  label: _titles[i],
                  selected: _selectedIndex == i,
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    Navigator.pop(context);
                  },
                ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: const Color.fromARGB(255, 102, 53, 161).withOpacity(.8), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Connecté en tant qu'administrateur",
                          style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xff181818),
            border: Border(
              bottom: BorderSide(color: Color(0xff262626), width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [

                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),

                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 134, 44, 190).withOpacity(.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(255, 120, 73, 145).withOpacity(.35)),
                    ),
                    child: Icon(
                      _icons[_selectedIndex],
                      color: const Color(0xffD4AF6A),
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      _titles[_selectedIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .2,
                      ),
                    ),
                  ),

                  IconButton(
  icon: const Icon(
    Icons.notifications_none_rounded,
    color: Colors.white70,
    size: 22,
  ),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: Color(0xffD4AF6A),
              ),
              SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xff4ADE80),
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aucune nouvelle notification.\nTout est à jour.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: Color(0xffD4AF6A),
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),

                  const SizedBox(width: 6),

                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Container(
        color: const Color(0xff121212),
        child: _screens[_selectedIndex],
      ),

      // ================= BOTTOM NAV =================

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xff181818),
          border: Border(
            top: BorderSide(color: Color(0xff262626), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            
          ),
        ),
      ),
    );
  }

  // ================= DRAWER ITEM =================

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffD4AF6A).withOpacity(.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: selected ? const Color(0xffD4AF6A) : Colors.white54),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xffD4AF6A),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAV ITEM =================


            
  }
