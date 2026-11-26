import 'package:flutter/material.dart';

const _blue = Color(0xFF4299E1);

class GenderStepBody extends StatelessWidget {

  const GenderStepBody({
    super.key,
    required this.gender,
    required this.onSelect,
  });


  /// 'female', 'male' ya null (abhi kuch select nahi)
  final String? gender;

  /// Card dabane par 'female' ya 'male' wapas bhejta hai
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _GenderCard(
              label: 'Female',
              imagePath: 'assets/images/female.webp',
              selected: gender == 'female',
              onTap: () => onSelect('female'),
              imageScale: 1.9,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _GenderCard(
              label: 'Male',
              imagePath: 'assets/images/male.webp',
              selected: gender == 'male',
              onTap: () => onSelect('male'),
              imageScale: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
    this.imageScale = 1.0, // naya: image kitni bari karni hai
  });

  final String label;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.62, // lambi card, screen ke hisaab se khud scale hoti hai
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected ? _blue : null,
            gradient: selected
                ? null
                : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF3FC), Colors.white],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _blue : const Color(0xFF9CA3AF),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    child: Transform.scale(
                      scale: imageScale,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        cacheWidth: 700,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_outline,
                          size: 64,
                          color: selected ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF6B7280),
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