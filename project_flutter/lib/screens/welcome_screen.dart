import 'package:flutter/material.dart';
import 'login_screen.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff090611),

      body: Stack(
        children: [

          //================ BACKGROUND =================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff12061E),
                  Color(0xff090611),
                  Color(0xff040308),
                ],
              ),
            ),
          ),

          //================ TOP GLOW =================

          AnimatedBuilder(
  animation: controller,
  builder: (_, child) {
    return Positioned(
      top: -180 + controller.value * 20,
      left: -120,
      child: child!,
    );
  },

  child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(.55),
                    blurRadius: 180,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          //================ BOTTOM GLOW =================

          AnimatedBuilder(
  animation: controller,
  builder: (_, child) {
    return Positioned(
      bottom: -220,
      right: -150 + controller.value * 25,
      child: child!,
    );
  },

  child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(.50),
                    blurRadius: 200,
                    spreadRadius: 45,
                  ),
                ],
              ),
            ),
          ),

          //================ BIG CIRCLE 1 =================

          Positioned(
            top: -170,
            left: size.width * .12,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                  width: 2,
                ),
              ),
            ),
          ),

          Positioned(
            top: -120,
            left: size.width * .22,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurpleAccent.withOpacity(.75),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(.45),
                    blurRadius: 70,
                  ),
                ],
              ),
            ),
          ),

          //================ BIG CIRCLE 2 =================

          Positioned(
            bottom: 190,
            left: size.width * .12,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                  width: 2,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 240,
            left: size.width * .22,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurpleAccent.withOpacity(.75),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(.45),
                    blurRadius: 70,
                  ),
                ],
              ),
            ),
          ),

          //================ CONTENT =================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(.10)),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "TASK MANAGEMENT",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 5),

                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.25),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.25),
                          shape: BoxShape.circle,
                        ),
                      ),

                    ],
                  ),

                  const Spacer(),

                  // CONTINUE PARTIE 2...
                  AnimatedSwitcher(
  duration: const Duration(milliseconds: 800),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Smarter Days\nBegin with your",
        style: TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),

      const SizedBox(height: 6),

      ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Color(0xff8B5CF6),
              Color(0xffC084FC),
            ],
          ).createShader(bounds);
        },
        child: const Text(
          "Future Workspace",
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      const SizedBox(height: 25),

      Text(
        "Manage projects, collaborate with your team and let Artificial Intelligence organize your work faster than ever.",
        style: TextStyle(
          color: Colors.white.withOpacity(.70),
          fontSize: 16,
          height: 1.8,
        ),
      ),

      const SizedBox(height: 45),

      //================ GET STARTED =================

      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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

                Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .3,
                  ),
                ),

                SizedBox(width: 12),

                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),

              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 25),

      //================ INDICATOR =================

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 28,
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff8B5CF6), Color(0xffC084FC)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff9C6CFF).withOpacity(.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(width: 6),

          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

        ],
      ),

      const SizedBox(height: 35),

    ],
  ),
),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}