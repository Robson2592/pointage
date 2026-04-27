import 'package:flutter/material.dart';

class MomentoBackground extends StatelessWidget {
  final Widget child;
  const MomentoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _Blob(color: const Color(0xFFDDE3FF), size: 300),
        ),
        Positioned(
          top: 300,
          left: -80,
          child: _Blob(color: const Color(0xFFE5D5FF), size: 250),
        ),
        Positioned(
          bottom: 100,
          right: -60,
          child: _Blob(color: const Color(0xFFFFE1F5), size: 280),
        ),
        Positioned(
          bottom: -50,
          left: -30,
          child: _Blob(color: const Color(0xFFFFEFE9), size: 220),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
