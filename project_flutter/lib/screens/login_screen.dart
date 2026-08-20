import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'chef_projet_dashboard.dart';
import 'employe_dashboard.dart';
import 'client_dashboard.dart';
import 'register_screen.dart';
import '../widgets/wavy_header_clipper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  // ================= LOGIN =================
  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (result['success']) {
      final role = result['data']['user']['role'];

      Widget destination;

      switch (role) {
        case 'admin':
          destination = const AdminDashboard();
          break;

        case 'chef_projet':
          destination = const ChefProjetDashboard();
          break;

        case 'employe':
          destination = const EmployeDashboard();
          break;

        case 'client':
          destination = const ClientDashboard();
          break;

        default:
          destination = const ChefProjetDashboard();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    } else {
      setState(() => _error = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 36, 59),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================

            WavyHeader(
              height: size.height * 0.30,
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
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
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      "assets/images/login_illustration.png",
                      width: 80,
                      height: 80,
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
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffB93BE0).withOpacity(.15),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    )
                  ],
                ),

                child: Column(
                  children: [

                    const Text(
                      "Connexion",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Connectez-vous pour continuer",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.55),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ================= EMAIL =================

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

                    const SizedBox(height: 18),

                    // ================= PASSWORD =================

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
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 7),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            color: Color(0xffB93BE0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

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
                          onPressed: _loading ? null : _login,
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
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Se connecter",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.55),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              color: Color(0xffB93BE0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Text(
                      "Ou continuer avec",
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