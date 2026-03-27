import 'package:flutter/material.dart';

class MicronutrientUnitConverterWidget extends StatefulWidget {
  final String ingredientName;
  final List<Map<String, dynamic>> micronutrients; // [{ name: '', amount: 0, unit: '', micronutrientId: '' }]
  final VoidCallback? onClose;

  const MicronutrientUnitConverterWidget({
    super.key,
    required this.ingredientName,
    required this.micronutrients,
    this.onClose,
  });

  @override
  State<MicronutrientUnitConverterWidget> createState() => _MicronutrientUnitConverterWidgetState();
}

class _MicronutrientUnitConverterWidgetState extends State<MicronutrientUnitConverterWidget> {
  late String _selectedTargetUnit;
  late Map<String, double> _convertedAmounts;

  // Micronutrient unit conversions
  // Most micronutrients use: mg → mcg (ug) → g
  static const Map<String, double> unitConversions = {
    'mg': 1.0,        // milligram
    'mcg': 0.001,     // microgram (ug)
    'g': 1000.0,      // gram
    'IU': 0.001,      // International Units (for vitamins)
  };

  @override
  void initState() {
    super.initState();
    _selectedTargetUnit = 'mg';
    _updateConversions();
  }

  void _updateConversions() {
    _convertedAmounts = {};
    for (final micro in widget.micronutrients) {
      final amount = (micro['amount'] as num?)?.toDouble() ?? 0.0;
      final currentUnit = micro['unit']?.toString() ?? 'mg';
      
      // Convert from current unit to base (mg)
      final baseAmount = amount * (unitConversions[currentUnit] ?? 1.0);
      
      // Convert from base (mg) to selected target unit
      final conversionFactor = unitConversions[_selectedTargetUnit] ?? 1.0;
      final converted = baseAmount / conversionFactor;
      
      _convertedAmounts[micro['micronutrientId']?.toString() ?? ''] = converted;
    }
  }

  void _onUnitChanged(String? newUnit) {
    if (newUnit != null) {
      setState(() {
        _selectedTargetUnit = newUnit;
        _updateConversions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Micronutrient Unit Converter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.onClose?.call();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredient Name
            Text(
              '${widget.ingredientName} - Micronutrients',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),

            // Unit Selector
            const Text(
              'Convert all to:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedTargetUnit,
                isExpanded: true,
                items: unitConversions.keys.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: _onUnitChanged,
              ),
            ),
            const SizedBox(height: 20),

            // Micronutrients List
            const Text(
              'Converted Values:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.micronutrients.length,
                itemBuilder: (context, index) {
                  final micro = widget.micronutrients[index];
                  final name = micro['micronutrientId'] is Map<String, dynamic>
                      ? (micro['micronutrientId'] as Map<String, dynamic>)['name']?.toString() ?? 'Nutrient'
                      : micro['name']?.toString() ?? 'Nutrient';
                  final originalAmount = (micro['amount'] as num?)?.toStringAsFixed(2) ?? '0.0';
                  final originalUnit = micro['unit']?.toString() ?? 'mg';
                  final microId = micro['micronutrientId']?.toString() ?? '';
                  final converted = _convertedAmounts[microId]?.toStringAsFixed(2) ?? '0.0';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Original',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '$originalAmount $originalUnit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Converted',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '$converted $_selectedTargetUnit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFF9800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
