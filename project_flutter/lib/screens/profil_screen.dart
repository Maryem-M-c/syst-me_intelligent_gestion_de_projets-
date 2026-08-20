import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'login_screen.dart';



class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final data = await ApiService.get('me');
    setState(() {
      _user = User.fromJson(data);
      _loading = false;
    });
  }

  String _libelleRole(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'chef_projet':
        return 'Chef de projet';
      case 'employe':
        return 'Employé';
      case 'client':
        return 'Client';
      default:
        return role;
    }
  }

  IconData _iconeRole(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'chef_projet':
        return Icons.manage_accounts;
      case 'employe':
        return Icons.badge;
      default:
        return Icons.person;
    }
  }

  Color _couleurRole(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xff9C6CFF);
      case 'chef_projet':
        return const Color(0xff5B8DEF);
      case 'employe':
        return const Color.fromARGB(255, 213, 176, 89);
      default:
        return const Color.fromARGB(255, 183, 116, 177);
    }
  }

  Future<void> _deconnexion() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
    if (_user == null) {
      return Container(
        color: const Color(0xff0E0A16),
        child: Center(
          child: Text(
            'Impossible de charger le profil',
            style: TextStyle(color: Colors.white.withOpacity(.6)),
          ),
        ),
      );
    }

    final role = _user!.role;
    final couleur = _couleurRole(role);

    return Container(
      color: const Color(0xff0E0A16),
      child: Stack(
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
                    color: couleur.withOpacity(.20),
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
                children: [

                  const SizedBox(height: 10),

                  // ================= AVATAR =================

                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [couleur, couleur.withOpacity(.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: couleur.withOpacity(.45),
                          blurRadius: 30,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(_iconeRole(role), size: 42, color: Colors.white),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    _user!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: couleur.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: couleur.withOpacity(.4)),
                    ),
                    child: Text(
                      _libelleRole(role),
                      style: TextStyle(color: couleur, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ================= STATUT COMPTE =================

                Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: const Color(0xff4ADE80).withOpacity(.10),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xff4ADE80).withOpacity(.25),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xff4ADE80),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 7),
      const Text(
        "Compte actif",
        style: TextStyle(
          color: Color(0xff4ADE80),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),
                    

                  const SizedBox(height: 15),

                  // ================= INFOS CARD =================

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                    ),
                    child: Column(
                      children: [

                        _infoTile(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: _user!.email,
                          couleur: couleur,
                        ),

                        Divider(color: Colors.white.withOpacity(.06), height: 1),

                        _infoTile(
                          icon: Icons.tag_rounded,
                          label: "Identifiant",
                          value: "#${_user!.id}",
                          couleur: couleur,
                        ),

                      ],
                    ),
                  ),

                  const Spacer(),

                  // ================= LOGOUT BUTTON =================

                  GestureDetector(
                    onTap: _deconnexion,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xffF87171).withOpacity(.12),
                        border: Border.all(color: const Color(0xffF87171).withOpacity(.35)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Color(0xffF87171), size: 19),
                          SizedBox(width: 10),
                          Text(
                            'Se déconnecter',
                            style: TextStyle(color: Color(0xffF87171), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
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

  // ================= INFO TILE =================

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color couleur,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: couleur.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: couleur, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}