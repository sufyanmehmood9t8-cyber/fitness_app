/// Step 4 – Weight selection step body.
///
/// Segmented control: lb | Kilogram
/// Single numeric field; converts on toggle.
/// Valid: 30–300 kg (or lb equivalent).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../constants/assessment_constants.dart';

class WeightStepBody extends StatefulWidget {
  const WeightStepBody({
    super.key,
    required this.weightKg,
    required this.selectedUnit,
    required this.onWeightKgChanged,
    required this.onUnitChanged,
  });

  final double weightKg;
  final WeightUnit selectedUnit;
  final ValueChanged<double> onWeightKgChanged;
  final ValueChanged<WeightUnit> onUnitChanged;

  @override
  State<WeightStepBody> createState() => _WeightStepBodyState();
}

class _WeightStepBodyState extends State<WeightStepBody> {
  late TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _displayValue(widget.weightKg, widget.selectedUnit));
    _ctrl.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(WeightStepBody old) {
    super.didUpdateWidget(old);
    // Re-sync when unit flips.
    if (old.selectedUnit != widget.selectedUnit) {
      final newText = _displayValue(widget.weightKg, widget.selectedUnit);
      _ctrl
        ..removeListener(_onChanged)
        ..text = newText
        ..addListener(_onChanged);
      setState(() => _error = null);
    }
  }

  String _displayValue(double kg, WeightUnit unit) {
    if (kg <= 0) return '';
    if (unit == WeightUnit.lb) {
      return kgToLb(kg).toStringAsFixed(1);
    }
    return kg.toStringAsFixed(1);
  }

  void _onChanged() {
    final text = _ctrl.text;
    final val = double.tryParse(text);
    if (val == null || text.isEmpty) return;

    final kg = widget.selectedUnit == WeightUnit.lb ? lbToKg(val) : val;
    final lbEquivMin = kgToLb(kMinWeightKg);
    final lbEquivMax = kgToLb(kMaxWeightKg);

    final outOfRange = widget.selectedUnit == WeightUnit.lb
        ? (val < lbEquivMin || val > lbEquivMax)
        : (kg < kMinWeightKg || kg > kMaxWeightKg);

    if (outOfRange) {
      setState(() => _error = widget.selectedUnit == WeightUnit.lb
          ? 'Enter weight between ${lbEquivMin.toStringAsFixed(0)} and ${lbEquivMax.toStringAsFixed(0)} lb'
          : 'Enter weight between ${kMinWeightKg.toStringAsFixed(0)} and ${kMaxWeightKg.toStringAsFixed(0)} kg');
      return;
    }
    setState(() => _error = null);
    widget.onWeightKgChanged(kg);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _WeightSegmentedControl(
          selected: widget.selectedUnit,
          onChanged: widget.onUnitChanged,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: kWeightPlaceholder,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.white,
              suffixText: widget.selectedUnit == WeightUnit.lb ? 'lb' : 'kg',
              suffixStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
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
}

class _WeightSegmentedControl extends StatelessWidget {
  const _WeightSegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final WeightUnit selected;
  final ValueChanged<WeightUnit> onChanged;

  static const _labels = <WeightUnit, String>{
    WeightUnit.lb: 'lb',
    WeightUnit.kg: 'Kilogram',
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
        children: WeightUnit.values.map((unit) {
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
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
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
