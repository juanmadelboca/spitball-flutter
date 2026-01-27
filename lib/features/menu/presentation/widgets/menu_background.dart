import 'dart:math';
import 'package:flutter/material.dart';

class MenuBackground extends StatefulWidget {
  const MenuBackground({super.key});

  @override
  State<MenuBackground> createState() => _MenuBackgroundState();
}

class _MenuBackgroundState extends State<MenuBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate initial particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_generateParticle());
    }
  }

  Particle _generateParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 20 + 5, // Smaller, square pixels
      speedX: (_random.nextDouble() - 0.5) * 0.001, // Slower for retro feel
      speedY: (_random.nextDouble() - 0.5) * 0.001,
      color: Colors.white.withValues(alpha: _random.nextDouble() * 0.1 + 0.02),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF212121), // Dark retro background
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_particles),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      // Wrap around screen
      if (particle.x < -0.1) particle.x = 1.1;
      if (particle.x > 1.1) particle.x = -0.1;
      if (particle.y < -0.1) particle.y = 1.1;
      if (particle.y > 1.1) particle.y = -0.1;

      // Draw Square (Pixel)
      final paint = Paint()..color = particle.color;
      canvas.drawRect(
        Rect.fromLTWH(
          particle.x * size.width, 
          particle.y * size.height, 
          particle.size, 
          particle.size
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
