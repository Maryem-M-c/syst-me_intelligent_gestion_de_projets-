import 'package:flutter/material.dart';

import 'projets_screen_client.dart';
import 'profil_screen.dart';

import 'assistant_nouveau_projet_screen.dart';


class ClientDashboard extends StatefulWidget {

  const ClientDashboard({super.key});


  @override
  State<ClientDashboard> createState() =>
      _ClientDashboardState();

}



class _ClientDashboardState extends State<ClientDashboard> {


  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final List<Widget> _screens = const [

    ProjetsScreenClient(),
    AssistantNouveauProjetScreen(),
    ProfilScreen(),

  ];



  final List<String> _titles = const [

    'Mes projets',

    'Nouveau projet (IA)',

    'Profil'

  ];

  final List<IconData> _icons = const [
    Icons.folder_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      key: _scaffoldKey,

      backgroundColor: const Color(0xff0D0710),

      // ================= DRAWER =================

      drawer: Drawer(
        backgroundColor: const Color(0xff160B1C),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xffEC4899), Color(0xffF43F5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffEC4899).withOpacity(.4),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond_rounded,
                          color: Colors.white, size: 21),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Espace Client",
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

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  "NAVIGATION",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.30),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xffEC4899).withOpacity(.15),
                        const Color(0xffF43F5E).withOpacity(.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xffEC4899).withOpacity(.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xffEC4899), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Connecté en tant que client",
                          style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 11.5),
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
        preferredSize: const Size.fromHeight(74),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2A0E2E),
                Color(0xffEC4899),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x55EC4899),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [

                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),

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
                      size: 19,
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
              Color(0xff17091C),
              Color(0xff0D0710),
            ],
          ),
        ),
        child: _screens[_selectedIndex],
      ),


      // ================= BOTTOM NAV =================

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xff1B0F22),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(.06)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffEC4899).withOpacity(.20),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < _titles.length; i++)
              _navItem(
                icon: _icons[i],
                label: _titles[i],
                selected: _selectedIndex == i,
                onTap: () => setState(() => _selectedIndex = i),
              ),
          ],
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
          gradient: selected
              ? LinearGradient(
                  colors: [
                    const Color(0xffEC4899).withOpacity(.18),
                    const Color(0xffF43F5E).withOpacity(.06),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: selected ? const Color(0xffEC4899) : Colors.white54),
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
                  color: Color(0xffEC4899),
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

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [Color(0xffEC4899), Color(0xffF43F5E)])
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : Colors.white30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: selected ? const Color(0xffEC4899) : Colors.white30,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

}