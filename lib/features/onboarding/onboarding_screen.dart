import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _blue = Color(0xFF4299E1);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinish});

  /// Optional: na diya jaye to neeche wala route khulega
  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _desc2 =
      'Stretch smarter, move with purpose, and feel better every day one '
      'simple habit that adds up to a healthier, more energized you.';

  void _next() {
    if (_index == 2) {
      if (widget.onFinish != null) {
        widget.onFinish!();
      } else {
        context.go('/assessment'); // <-- apne router ka path yahan likhein
      }
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    final pages = <_Page>[
      const _Page(
        hero: _HeroImage('assets/images/onboarding_1.webp'),
        title: 'Improve Flexibility',
        text: 'Stretch smarter, improve your flexibility, and feel better '
            'every day — one simple habit that adds up to a healthier, '
            'more energized you.',
      ),
      const _Page(
        hero: _HeroImage('assets/images/onboarding_2.webp'),
        title: 'Stretch smarter Feel better every day.',
        text: _desc2,
      ),
      const _Page(
        hero: ExerciseCircleCluster(),
        title: 'Multiple exercise practice',
        text: _desc2,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1EEFF), Color(0xFFF8FAFF), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: pages,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x594299E1),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Next',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
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
}

class _Page extends StatelessWidget {
  const _Page({required this.hero, required this.title, required this.text});
  final Widget hero;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 6, child: Center(child: hero)),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        cacheWidth: 900,
        errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

/// Page 3 hero: bada circle beech mein, 4 chhote circles dotted lines ke saath
class ExerciseCircleCluster extends StatefulWidget {
  const ExerciseCircleCluster({super.key});

  @override
  State<ExerciseCircleCluster> createState() => _ExerciseCircleClusterState();
}

class _ExerciseCircleClusterState extends State<ExerciseCircleCluster>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  // Jab onb3_* images tayyar hon to sirf yeh paths badal dein
  static const _center = 'assets/images/center.webp';
  static const _top = 'assets/images/top.webp';
  static const _left = 'assets/images/left.webp';
  static const _right = 'assets/images/right.webp';
  static const _bottom = 'assets/images/bottom.webp';

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _circle(String asset, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x404299E1),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          cacheWidth: 400,
          errorBuilder: (_, __, ___) =>
          const ColoredBox(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  Widget _floating(double phase, Widget child) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, c) => Transform.translate(
        offset: Offset(0, 4 * math.sin((_anim.value + phase) * 2 * math.pi)),
        child: c,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 320x320 ke base par bana hai, har screen par FittedBox se scale hota hai
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DottedLinesPainter())),
            Positioned(left: 105, top: 105, child: _circle(_center, 110)),
            Positioned(left: 132, top: 12, child: _floating(0.0, _circle(_top, 56))),
            Positioned(left: 12, top: 132, child: _floating(0.25, _circle(_left, 56))),
            Positioned(left: 252, top: 132, child: _floating(0.5, _circle(_right, 56))),
            Positioned(left: 132, top: 252, child: _floating(0.75, _circle(_bottom, 56))),
          ],
        ),
      ),
    );
  }
}

class _DottedLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _blue.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    void dashed(Offset a, Offset b) {
      const dash = 3.0, gap = 3.0;
      final total = (b - a).distance;
      final dir = (b - a) / total;
      double d = 0;
      while (d < total) {
        final end = math.min(d + dash, total);
        canvas.drawLine(a + dir * d, a + dir * end, paint);
        d += dash + gap;
      }
    }

    dashed(const Offset(160, 68), const Offset(160, 105));   // top
    dashed(const Offset(160, 215), const Offset(160, 252));  // bottom
    dashed(const Offset(68, 160), const Offset(105, 160));   // left
    dashed(const Offset(215, 160), const Offset(252, 160));  // right
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}