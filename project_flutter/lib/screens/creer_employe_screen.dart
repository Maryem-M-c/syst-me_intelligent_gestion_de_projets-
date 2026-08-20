import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreerEmployeScreen extends StatefulWidget {
  const CreerEmployeScreen({super.key});

  @override
  State<CreerEmployeScreen> createState() => _CreerEmployeScreenState();
}

class _CreerEmployeScreenState extends State<CreerEmployeScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _competencesController = TextEditingController();

  int _niveau = 3;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _creer() async {
    if (_nomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _competencesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff102420),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'Merci de remplir tous les champs',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.post(
        'employes',
        {
          "name": _nomController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "competences": _competencesController.text,
          "niveau": _niveau,
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff102420),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text("Erreur : $e", style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 14, 7, 20),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          color: const Color(0xff071411),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      color: const Color.fromARGB(255, 237, 190, 239).withOpacity(.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromARGB(255, 212, 127, 221).withOpacity(.3)),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color.fromARGB(255, 166, 115, 182),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Nouvel employé",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .2,
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
              Color.fromARGB(255, 153, 132, 173),
              Color(0xff071411),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            children: [

              Text(
                "INFORMATIONS PERSONNELLES",
                style: TextStyle(
                  color: const Color.fromARGB(255, 239, 236, 236).withOpacity(.35),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              // ================= CARD =================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 158, 132, 167),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color.fromARGB(255, 226, 232, 230), width: 1),
                ),
                child: Column(
                  children: [

                    _buildField(
                      controller: _nomController,
                      hint: "Nom complet",
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      controller: _emailController,
                      hint: "Adresse email",
                      icon: Icons.alternate_email_rounded,
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      controller: _passwordController,
                      hint: "Mot de passe",
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 19,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      controller: _competencesController,
                      hint: "Compétences",
                      icon: Icons.psychology_outlined,
                      subHint: "Laravel, Flutter, MySQL",
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                "NIVEAU D'EXPERTISE",
                style: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              // ================= NIVEAU CARD =================

              Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 16, 11, 18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color.fromARGB(255, 175, 136, 187), width: 1),
                ),
                child: Column(
                  children: [

                    Text(
                      "$_niveau / 5",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 154, 93, 166),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Niveau d'expertise",
                      style: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 12.5),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 34,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: index < _niveau
                                ? const Color.fromARGB(255, 170, 117, 172)
                                : Colors.white.withOpacity(.08),
                          ),
                        );
                      }),
                    ),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color.fromARGB(255, 173, 111, 183),
                        inactiveTrackColor: Colors.white.withOpacity(.08),
                        thumbColor: const Color.fromARGB(255, 164, 34, 204),
                        overlayColor: const Color.fromARGB(255, 131, 86, 160).withOpacity(.15),
                        valueIndicatorColor: const Color.fromARGB(255, 193, 103, 211),
                        valueIndicatorTextStyle: const TextStyle(color: Color(0xff071411), fontWeight: FontWeight.bold),
                      ),
                      child: Slider(
                        value: _niveau.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: "$_niveau",
                        onChanged: (value) {
                          setState(() {
                            _niveau = value.round();
                          });
                        },
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: _loading ? null : _creer,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color.fromARGB(255, 171, 121, 188),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff34D399).withOpacity(.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xff071411),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: Color(0xff071411), size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Créer l'employé",
                                style: TextStyle(
                                  color: Color(0xff071411),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE FIELD =================

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    String? subHint,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xff071411),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: const Color.fromARGB(255, 7, 23, 17),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 13),
          hintText: subHint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(.22)),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 138, 107, 165), size: 19),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}