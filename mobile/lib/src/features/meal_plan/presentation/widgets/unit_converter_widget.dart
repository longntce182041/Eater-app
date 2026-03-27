import 'package:flutter/material.dart';

class UnitConverterWidget extends StatefulWidget {
  final String ingredientName;
  final double baseQuantity;
  final String baseUnit;
  final VoidCallback? onClose;

  const UnitConverterWidget({
    super.key,
    required this.ingredientName,
    required this.baseQuantity,
    required this.baseUnit,
    this.onClose,
  });

  @override
  State<UnitConverterWidget> createState() => _UnitConverterWidgetState();
}

class _UnitConverterWidgetState extends State<UnitConverterWidget> {
  late String _selectedUnit;
  late double _convertedQuantity;

  // Conversion factors to grams (base unit)
  static const Map<String, double> conversions = {
    'grams': 1.0,
    'kg': 1000.0,
    'oz (US)': 28.35,
    'oz (UK)': 28.35,
    'lb': 453.592,
    'ml': 1.0, // For liquids, 1ml ≈ 1g
    'l': 1000.0,
    'cup (US)': 236.588,
    'cup (UK)': 284.131,
    'tbsp': 14.787,
    'tsp': 4.929,
    'serving': 100.0, // Default serving size
  };

  @override
  void initState() {
    super.initState();
    // Ensure _selectedUnit is always a valid unit from conversions map
    _selectedUnit = (widget.baseUnit.isNotEmpty && conversions.containsKey(widget.baseUnit))
        ? widget.baseUnit
        : 'grams';
    _updateConversion();
  }

  void _updateConversion() {
    // Convert baseQuantity (assumed to be in grams or the baseUnit)
    // to the selected unit
    final baseInGrams = widget.baseQuantity;
    final conversionFactor = conversions[_selectedUnit] ?? 1.0;
    _convertedQuantity = baseInGrams / conversionFactor;
  }

  void _onUnitChanged(String? newUnit) {
    if (newUnit != null) {
      setState(() {
        _selectedUnit = newUnit;
        _updateConversion();
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
                  'Unit Converter',
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
              widget.ingredientName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),

            // Base Amount Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Base Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.baseQuantity.toStringAsFixed(2)} ${widget.baseUnit}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Unit Selector
            const Text(
              'Convert to:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              items: conversions.keys.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: _onUnitChanged,
              hint: const Text('Select unit'),
            ),
            const SizedBox(height: 20),

            // Converted Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF9800),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Converted Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_convertedQuantity.toStringAsFixed(2)} $_selectedUnit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Copy Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_convertedQuantity.toStringAsFixed(2)} $_selectedUnit copied',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Use This Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
