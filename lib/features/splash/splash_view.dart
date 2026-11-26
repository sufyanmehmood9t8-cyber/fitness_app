import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  static const Color _background = Color(0xFF101820);
  static const Color _accent = Color(0xFF4299E1);
  static const Color _taglineColor = Color(0xFF9DB8D9);

  late final AnimationController _intro;
  late final AnimationController _loop;
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final random = math.Random(7);
    _bubbles = List<_Bubble>.generate(16, (index) {
      return _Bubble(
        x: random.nextDouble(),
        size: 10 + random.nextDouble() * 38,
        speed: random.nextInt(2) + 1,
        phase: random.nextDouble(),
        opacity: 0.10 + random.nextDouble() * 0.22,
        isRing: random.nextBool(),
      );
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: _background,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            RepaintBoundary(
              child: CustomPaint(
                painter: _BubblePainter(
                  intro: _intro,
                  loop: _loop,
                  bubbles: _bubbles,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildHero(),
                    const SizedBox(height: 22),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildTagline(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset + 40,
              child: Center(child: _buildLoader()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: _intro,
            builder: (context, child) {
              final opacity = const Interval(
                0.0,
                0.35,
                curve: Curves.easeOut,
              ).transform(_intro.value);
              return Opacity(opacity: opacity, child: child);
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    _accent.withValues(alpha: 0.30),
                    _accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          for (final offset in const <double>[0.0, 0.5])
            AnimatedBuilder(
              animation: _loop,
              builder: (context, child) {
                final t = (_loop.value * 4 + offset) % 1.0;
                final size = 90 + 120 * t;
                return Opacity(
                  opacity: 0.38 * (1 - t),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _accent, width: 1.5),
                    ),
                  ),
                );
              },
            ),
          _buildLogo(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.05, 0.30, curve: Curves.easeOut),
    );
    final scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.05, 0.40, curve: Curves.easeOutBack),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _accent.withValues(alpha: 0.55),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final animation = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.30, 0.55, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Text(
        'FLOW',
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 34,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          letterSpacing: 3,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    final animation = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: const Text(
        'Move. Stretch. Repeat.',
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: _taglineColor,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 64,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(
              color: Colors.white.withValues(alpha: 0.15),
            ),
            AnimatedBuilder(
              animation: _intro,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _intro.value,
                    heightFactor: 1,
                    child: const ColoredBox(color: _accent),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.isRing,
  });

  final double x;
  final double size;
  final int speed;
  final double phase;
  final double opacity;
  final bool isRing;
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.intro,
    required this.loop,
    required this.bubbles,
  }) : super(repaint: Listenable.merge(<Listenable>[intro, loop]));

  final Animation<double> intro;
  final Animation<double> loop;
  final List<_Bubble> bubbles;

  @override
  void paint(Canvas canvas, Size size) {
    final double appear =
        (intro.value / 0.3).clamp(0.0, 1.0).toDouble();
    if (appear <= 0) return;

    final paint = Paint();

    for (final bubble in bubbles) {
      final cycle = loop.value * bubble.speed + bubble.phase;
      final p = cycle % 1.0;
      final y = size.height * (1.08 - p * 1.2);
      final x = size.width * bubble.x +
          math.sin(cycle * 2 * math.pi) * 14;
      final alpha = bubble.opacity * math.sin(math.pi * p) * appear;
      if (alpha <= 0) continue;

      paint.color = const Color(0xFF4299E1).withValues(alpha: alpha);

      if (bubble.isRing) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawCircle(Offset(x, y), bubble.size / 2, paint);
      } else {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), bubble.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => false;
}
