import 'package:flutter/material.dart';

/// Découpe une vague en bas du header, comme sur la maquette.
class WavyHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.55, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint =
        Offset(size.width * 0.85, size.height * 0.65);
    final secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Header violet/rose avec dégradé et forme ondulée, réutilisé sur les 2 pages.
class WavyHeader extends StatelessWidget {
  final double height;
  final Widget? child;

  const WavyHeader({super.key, this.height = 260, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WavyHeaderClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff7B2FF7), // violet
              Color(0xffB93BE0), // magenta
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}