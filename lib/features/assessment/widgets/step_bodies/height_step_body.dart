/// Step 3 – Height selection step body.
///
/// Segmented control: Feet | CM | M
/// Feet mode: wheel pickers for feet (3–8) and inches (0–11).
/// CM mode: text field, valid 50–250.
/// M mode: text field, valid 0.5–2.5.
/// Converting units preserves the same real-world height.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../constants/assessment_constants.dart';

class HeightStepBody extends StatefulWidget {
  const HeightStepBody({
    super.key,
    required this.heightCm,
    required this.selectedUnit,
    required this.heightFeet,
    required this.heightInches,
    required this.onHeightCmChanged,
    required this.onUnitChanged,
    required this.onFeetInchesChanged,
  });

  final double heightCm;
  final HeightUnit selectedUnit;
  final int heightFeet;
  final int heightInches;
  final ValueChanged<double> onHeightCmChanged;
  final ValueChanged<HeightUnit> onUnitChanged;
  final void Function(int feet, int inches) onFeetInchesChanged;

  @override
  State<HeightStepBody> createState() => _HeightStepBodyState();
}

class _HeightStepBodyState extends State<HeightStepBody> {
  late TextEditingController _cmCtrl;
  late TextEditingController _mCtrl;
  late FixedExtentScrollController _feetCtrl;
  late FixedExtentScrollController _inchesCtrl;

  String? _error;

  @override
  void initState() {
    super.initState();
    final cm = widget.heightCm > 0 ? widget.heightCm : kDefaultFeet * 30.48 + kDefaultInches * 2.54;
    _cmCtrl = TextEditingController(text: cm.toStringAsFixed(1));
    _mCtrl = TextEditingController(text: (cm / 100).toStringAsFixed(2));
    _feetCtrl = FixedExtentScrollController(
      initialItem: (widget.heightFeet - kMinFeet).clamp(0, kMaxFeet - kMinFeet),
    );
    _inchesCtrl = FixedExtentScrollController(
      initialItem: widget.heightInches.clamp(0, 11),
    );
  }

  @override
  void dispose() {
    _cmCtrl.dispose();
    _mCtrl.dispose();
    _feetCtrl.dispose();
    _inchesCtrl.dispose();
    super.dispose();
  }

  void _onCmChanged(String v) {
    final val = double.tryParse(v);
    if (val == null) return;
    if (val < kMinHeightCm || val > kMaxHeightCm) {
      setState(() => _error = 'Enter height between 50 and 250 cm');
      return;
    }
    setState(() => _error = null);
    widget.onHeightCmChanged(val);
  }

  void _onMChanged(String v) {
    final val = double.tryParse(v);
    if (val == null) return;
    if (val < kMinHeightM || val > kMaxHeightM) {
      setState(() => _error = 'Enter height between 0.5 and 2.5 m');
      return;
    }
    setState(() => _error = null);
    widget.onHeightCmChanged(val * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SegmentedControl(
          selected: widget.selectedUnit,
          onChanged: widget.onUnitChanged,
        ),
        const SizedBox(height: 20),
        _buildInput(),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFFE5484D),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInput() {
    switch (widget.selectedUnit) {
      case HeightUnit.feet:
        return _FeetPicker(
          feetCtrl: _feetCtrl,
          inchesCtrl: _inchesCtrl,
          onChanged: widget.onFeetInchesChanged,
        );
      case HeightUnit.cm:
        return _numericField(
          ctrl: _cmCtrl,
          onChanged: _onCmChanged,
          hint: kHeightPlaceholder,
          suffix: 'cm',
          decimal: true,
        );
      case HeightUnit.m:
        return _numericField(
          ctrl: _mCtrl,
          onChanged: _onMChanged,
          hint: kHeightPlaceholder,
          suffix: 'm',
          decimal: true,
        );
    }
  }

  Widget _numericField({
    required TextEditingController ctrl,
    required ValueChanged<String> onChanged,
    required String hint,
    required String suffix,
    bool decimal = false,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          filled: true,
          fillColor: AppColors.white,
          suffixText: suffix,
          suffixStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Segmented control
// ──────────────────────────────────────────────────────────────

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final HeightUnit selected;
  final ValueChanged<HeightUnit> onChanged;

  static const _labels = <HeightUnit, String>{
    HeightUnit.feet: 'Feet',
    HeightUnit.cm: 'CM',
    HeightUnit.m: 'M',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: HeightUnit.values.map((unit) {
          final isSelected = unit == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(unit),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[unit]!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Feet + Inches wheel picker
// ──────────────────────────────────────────────────────────────

class _FeetPicker extends StatefulWidget {
  const _FeetPicker({
    required this.feetCtrl,
    required this.inchesCtrl,
    required this.onChanged,
  });

  final FixedExtentScrollController feetCtrl;
  final FixedExtentScrollController inchesCtrl;
  final void Function(int feet, int inches) onChanged;

  @override
  State<_FeetPicker> createState() => _FeetPickerState();
}

class _FeetPickerState extends State<_FeetPicker> {
  late int _feet;
  late int _inches;

  @override
  void initState() {
    super.initState();
    _feet = widget.feetCtrl.initialItem + kMinFeet;
    _inches = widget.inchesCtrl.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: <Widget>[
          // "Feet" label
          const SizedBox(
            width: 56,
            child: Center(
              child: Text(
                'Feet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          // Feet wheel
          Expanded(
            child: _Wheel(
              controller: widget.feetCtrl,
              itemCount: kMaxFeet - kMinFeet + 1,
              labelBuilder: (i) => '${i + kMinFeet}',
              onSelected: (i) {
                _feet = i + kMinFeet;
                widget.onChanged(_feet, _inches);
              },
            ),
          ),
          // "Inches" label
          const SizedBox(
            width: 56,
            child: Center(
              child: Text(
                'Inches',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          // Inches wheel
          Expanded(
            child: _Wheel(
              controller: widget.inchesCtrl,
              itemCount: kMaxInches - kMinInches + 1,
              labelBuilder: (i) => '$i',
              onSelected: (i) {
                _inches = i;
                widget.onChanged(_feet, _inches);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}


class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return _WheelItem(
            label: labelBuilder(index),
          );
        },
      ),
    );
  }
}

class _WheelItem extends StatelessWidget {
  const _WheelItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Determine if this item is at the centre of its parent wheel.
    // We use a LayoutBuilder trick via NotificationListener upstream.
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
