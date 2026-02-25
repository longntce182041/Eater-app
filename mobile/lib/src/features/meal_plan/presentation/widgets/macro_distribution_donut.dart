import 'package:flutter/material.dart';
import 'dart:math' as math;

class MacroDistributionDonut extends StatefulWidget {
  final double protein;
  final double carbohydrates;
  final double fat;
  final List<double>? micronutrients;
  final VoidCallback? onViewAll;

  const MacroDistributionDonut({
    super.key,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.micronutrients,
    this.onViewAll,
  });

  @override
  State<MacroDistributionDonut> createState() => _MacroDistributionDonutState();
}

class _MacroDistributionDonutState extends State<MacroDistributionDonut> {
  late List<_MacroData> macroData;

  @override
  void initState() {
    super.initState();
    _initMacroData();
  }

  void _initMacroData() {
    macroData = [
      _MacroData(
        label: 'Protein',
        value: widget.protein,
        color: const Color(0xFF42A5F5),
        abbreviation: 'P',
      ),
      _MacroData(
        label: 'Carbs',
        value: widget.carbohydrates,
        color: const Color(0xFFFFC107),
        abbreviation: 'C',
      ),
      _MacroData(
        label: 'Fat',
        value: widget.fat,
        color: const Color(0xFFFF7043),
        abbreviation: 'F',
      ),
    ];
  }

  @override
  void didUpdateWidget(MacroDistributionDonut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.protein != widget.protein ||
        oldWidget.carbohydrates != widget.carbohydrates ||
        oldWidget.fat != widget.fat) {
      setState(() {
        _initMacroData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.protein + widget.carbohydrates + widget.fat;

    return Column(
      children: [
        LimitedBox(
          maxHeight: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _DonutChartPainter(
                  macroData: macroData,
                  total: total,
                  strokeWidth: 28,
                ),
                size: Size.infinite,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    total.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const Text(
                    'grams',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: macroData.map((macro) {
              final percentage =
                  total > 0 ? (macro.value / total * 100).toStringAsFixed(1) : '0.0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: macro.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        macro.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${macro.value.toStringAsFixed(0)}g ($percentage%)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.onViewAll != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'View detailed breakdown',
                style: TextStyle(
                  color: Color.fromARGB(255, 17, 14, 9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MacroData {
  final String label;
  final String abbreviation;
  final double value;
  final Color color;

  _MacroData({
    required this.label,
    required this.abbreviation,
    required this.value,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_MacroData> macroData;
  final double total;
  final double strokeWidth;

  _DonutChartPainter({
    required this.macroData,
    required this.total,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    var startAngle = -math.pi / 2;

    for (final macro in macroData) {
      final sweepAngle = (macro.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = macro.color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    if (oldDelegate.total != total) return true;
    if (oldDelegate.macroData.length != macroData.length) return true;
    
    for (int i = 0; i < macroData.length; i++) {
      if (oldDelegate.macroData[i].value != macroData[i].value) {
        return true;
      }
    }
    return false;
  }
}
