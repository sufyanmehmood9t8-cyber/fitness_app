/// Step 7 – Sitting hours numeric input step body.
///
/// Single numeric field, valid 0–24, decimals allowed.
/// Shows inline red error if value is out of range.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../constants/assessment_constants.dart';

class SittingHoursStepBody extends StatefulWidget {
  const SittingHoursStepBody({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  /// -1 means not yet set.
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  State<SittingHoursStepBody> createState() => _SittingHoursStepBodyState();
}

class _SittingHoursStepBodyState extends State<SittingHoursStepBody> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initText =
        widget.initialValue >= 0 ? widget.initialValue.toString() : '';
    _ctrl = TextEditingController(text: initText);
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    final text = _ctrl.text;
    if (text.isEmpty) {
      setState(() => _error = null);
      return;
    }
    final val = double.tryParse(text);
    if (val == null) {
      setState(() => _error = 'Please enter a valid number');
      return;
    }
    if (val < kMinSittingHours || val > kMaxSittingHours) {
      setState(() => _error =
          'Enter a value between ${kMinSittingHours.toStringAsFixed(0)} and ${kMaxSittingHours.toStringAsFixed(0)} hours');
      return;
    }
    setState(() => _error = null);
    widget.onChanged(val);
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
        SizedBox(
          height: 44,
          child: TextField(
            controller: _ctrl,
            autofocus: false,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: kSittingHoursPlaceholder,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.white,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE5484D)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE5484D), width: 1.5),
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
