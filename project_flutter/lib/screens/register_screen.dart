import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'client_dashboard.dart';
import '../widgets/wavy_header_clipper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ClientDashboard(),
        ),
      );
    } else {
      setState(() => _error = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 44, 36, 59),
      body: SingleChildScrollView(
        child: Column(
          children: [

            //================ HEADER ==================

            WavyHeader(
              height: size.height * 0.28,
              child: Center(
                child: Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      "assets/images/register_illustration.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -35),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xff1B1128),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffB93BE0).withOpacity(.15),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      "Inscrivez-vous pour commencer",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.55),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    //================ NOM ==================

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(.10)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xffB93BE0),
                        decoration: InputDecoration(
                          hintText: "Nom complet",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xffB93BE0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    //================ EMAIL ==================

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(.10)),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xffB93BE0),
                        decoration: InputDecoration(
                          hintText: "Adresse e-mail",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xffB93BE0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    //================ PASSWORD ==================

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(.10)),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xffB93BE0),
                        decoration: InputDecoration(
                          hintText: "Mot de passe",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xffB93BE0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white38,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.redAccent.withOpacity(.35)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // ================= BOUTON =================

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xff7B2FF7), Color(0xffB93BE0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffB93BE0).withOpacity(.4),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Créer un compte",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous avez déjà un compte ?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.55),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                              color: Color(0xffB93BE0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),

                    Text(
                      "Ou s'inscrire avec",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.35),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(
                          Icons.facebook,
                          const Color(0xff1877F2),
                        ),
                        const SizedBox(width: 20),
                        _socialIcon(
                          Icons.g_mobiledata,
                          const Color(0xffEA4335),
                          size: 38,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(
    IconData icon,
    Color color, {
    double size = 24,
  }) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}