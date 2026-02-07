import 'dart:math';
import 'package:flutter/material.dart';

class MathParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double angle;
  double rotationSpeed;
  double rotation;
  String symbol;

  MathParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
    required this.rotationSpeed,
    required this.rotation,
    required this.symbol,
  });
}

class MathParticlesBackground extends StatefulWidget {
  final Color backgroundColor;
  final Color particleColor;
  final int particleCount;
  final Widget? child;

  const MathParticlesBackground({
    super.key,
    this.backgroundColor = const Color(0xFF272837),
    this.particleColor = Colors.white,
    this.particleCount = 40,
    this.child,
  });

  @override
  State<MathParticlesBackground> createState() => _MathParticlesBackgroundState();
}

class _MathParticlesBackgroundState extends State<MathParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<MathParticle> _particles = [];
  final Random _random = Random();

  // Symbole matematyczne do wyświetlenia
  static const List<String> _symbols = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '+', '-', '×', '÷', '=', '%',
    '√', 'π', '∞', '^',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);

    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicjalizuj cząsteczki po uzyskaniu rozmiaru ekranu
    if (_particles.isEmpty) {
      _initParticles();
    }
  }

  void _initParticles() {
    final size = MediaQuery.of(context).size;
    _particles.clear();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createParticle(size, randomY: true));
    }
  }

  MathParticle _createParticle(Size screenSize, {bool randomY = false}) {
    return MathParticle(
      x: _random.nextDouble() * screenSize.width,
      y: randomY
          ? _random.nextDouble() * screenSize.height
          : screenSize.height + _random.nextDouble() * 100,
      size: _random.nextDouble() * 20 + 14, // 14-34
      speed: _random.nextDouble() * 0.8 + 0.3, // 0.3-1.1
      opacity: _random.nextDouble() * 0.15 + 0.05, // 0.05-0.2
      angle: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
      rotation: _random.nextDouble() * 2 * pi,
      symbol: _symbols[_random.nextInt(_symbols.length)],
    );
  }

  void _updateParticles() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;

    for (var particle in _particles) {
      // Ruch w górę z lekkim falowaniem
      particle.y -= particle.speed;
      particle.x += sin(particle.angle) * 0.3;
      particle.angle += 0.01;
      particle.rotation += particle.rotationSpeed;

      // Resetuj cząsteczkę gdy wyjdzie poza ekran
      if (particle.y < -50) {
        particle.x = _random.nextDouble() * size.width;
        particle.y = size.height + _random.nextDouble() * 50;
        particle.symbol = _symbols[_random.nextInt(_symbols.length)];
        particle.opacity = _random.nextDouble() * 0.15 + 0.05;
        particle.size = _random.nextDouble() * 20 + 14;
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // Warstwa cząsteczek
          CustomPaint(
            painter: _ParticlesPainter(
              particles: _particles,
              color: widget.particleColor,
            ),
            size: Size.infinite,
          ),
          // Zawartość na wierzchu
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<MathParticle> particles;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.symbol,
          style: TextStyle(
            color: color.withValues(alpha: particle.opacity),
            fontSize: particle.size,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}


