import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class PlateCalculatorDialog extends StatefulWidget {
  final double initialWeight;

  const PlateCalculatorDialog({super.key, this.initialWeight = 60.0});

  static void show(BuildContext context, {double initialWeight = 60.0}) {
    showDialog(
      context: context,
      builder: (_) => PlateCalculatorDialog(initialWeight: initialWeight),
    );
  }

  @override
  State<PlateCalculatorDialog> createState() => _PlateCalculatorDialogState();
}

class _PlateCalculatorDialogState extends State<PlateCalculatorDialog> {
  late double _targetWeight;
  double _barWeight = 20.0;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _targetWeight = widget.initialWeight > 0 ? widget.initialWeight : 60.0;
    _controller = TextEditingController(text: _targetWeight.toStringAsFixed(1).replaceAll('.0', ''));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getPlateColor(double plate) {
    if (plate >= 25) return const Color(0xFFE53935); // أحمر
    if (plate >= 20) return const Color(0xFF1E88E5); // أزرق
    if (plate >= 15) return const Color(0xFFFDD835); // أصفر
    if (plate >= 10) return const Color(0xFF43A047); // أخضر
    if (plate >= 5) return const Color(0xFFE0E0E0);  // أبيض/رمادي
    if (plate >= 2.5) return const Color(0xFF424242); // أسود
    return const Color(0xFF90A4AE); // كروم / فضي
  }

  double _getPlateHeight(double plate) {
    if (plate >= 25) return 80.0;
    if (plate >= 20) return 74.0;
    if (plate >= 15) return 66.0;
    if (plate >= 10) return 56.0;
    if (plate >= 5) return 46.0;
    if (plate >= 2.5) return 38.0;
    return 30.0;
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final platesPerSide = workout.calculatePlates(_targetWeight, barWeightKg: _barWeight);
    final weightPerSide = (_targetWeight - _barWeight) / 2.0;

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppTheme.primaryNeon, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.t('plate_calc_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          workout.t('plate_calc_subtitle'),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // حقل إدخال الوزن المطلوب مع أزرار الزيادة السريعة
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: workout.t('target_weight'),
                        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        suffixText: workout.t('kg_unit'),
                        suffixStyle: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: AppTheme.surfaceHigher,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _targetWeight = double.tryParse(val) ?? _barWeight;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // اختيار وزن البار
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHigher,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButton<double>(
                      value: _barWeight,
                      dropdownColor: AppTheme.surfaceHigher,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 20.0, child: Text('بار 20 كجم (Olympic)')),
                        DropdownMenuItem(value: 15.0, child: Text('بار 15 كجم (Women)')),
                        DropdownMenuItem(value: 10.0, child: Text('بار 10 كجم (EZ/Short)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _barWeight = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // أزرار سريعة لتعديل الوزن (+2.5, +5, +10, -2.5, -5, -10)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _quickWeightBtn('-10', -10),
                    _quickWeightBtn('-5', -5),
                    _quickWeightBtn('-2.5', -2.5),
                    const SizedBox(width: 10),
                    _quickWeightBtn('+2.5', 2.5, isNeon: true),
                    _quickWeightBtn('+5', 5, isNeon: true),
                    _quickWeightBtn('+10', 10, isNeon: true),
                    _quickWeightBtn('+20', 20, isNeon: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // المحاكاة الرسومية للبار والبليتات (Barbell Sleeve Simulation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      _targetWeight < _barWeight
                          ? workout.t('weight_less_than_bar')
                          : (_targetWeight == _barWeight
                              ? workout.t('no_plates_needed')
                              : '${workout.t('plates_per_side')} ${(weightPerSide).toStringAsFixed(2)} ${workout.t('kg_unit')}'),
                      style: TextStyle(
                        color: _targetWeight < _barWeight ? Colors.redAccent : AppTheme.primaryNeon,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // رسم البار الأفقي مع البليتات
                    SizedBox(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // كم البار الداخلي (Bar Collar)
                          Container(
                            width: 14,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // محور البار الأساسي (Bar Shaft)
                          Container(
                            width: 30,
                            height: 12,
                            color: Colors.grey.shade600,
                          ),
                          // البليتات مصفوفة بالترتيب
                          if (platesPerSide.isNotEmpty)
                            ...platesPerSide.entries.expand((entry) {
                              final pWeight = entry.key;
                              final count = entry.value;
                              return List.generate(count, (i) {
                                return Container(
                                  width: 14,
                                  height: _getPlateHeight(pWeight),
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: _getPlateColor(pWeight),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: Colors.black45, width: 1),
                                    boxShadow: [
                                      BoxShadow(color: _getPlateColor(pWeight).withValues(alpha: 0.3), blurRadius: 4),
                                    ],
                                  ),
                                  child: Center(
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        pWeight.toString().replaceAll('.0', ''),
                                        style: TextStyle(
                                          color: pWeight >= 15 ? Colors.black : Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            })
                          else if (_targetWeight >= _barWeight) ...[
                            // بار فارغ
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceHighlight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('بار فارغ 20kg', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                            ),
                          ],
                          // طرف البار الخارجي (Sleeve Tip)
                          Container(
                            width: 40,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // قائمة نصية واضحة بعدد كل بليتة
              if (platesPerSide.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: platesPerSide.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigher,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getPlateColor(e.key), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getPlateColor(e.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.value} × ${e.key} ${workout.t('kg_unit')}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(workout.t('close'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickWeightBtn(String label, double addWeight, {bool isNeon = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _targetWeight = (_targetWeight + addWeight).clamp(0.0, 500.0);
            _controller.text = _targetWeight.toStringAsFixed(1).replaceAll('.0', '');
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isNeon ? AppTheme.primaryNeon.withValues(alpha: 0.15) : AppTheme.surfaceHigher,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isNeon ? AppTheme.primaryNeon : AppTheme.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isNeon ? AppTheme.primaryNeon : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
