import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_log_provider.dart';
import '../../domain/entities/meal_log.dart';
import '../../data/providers/meal_log_service_provider.dart';

class EditMealLogPage extends ConsumerStatefulWidget {
  final MealLog mealLog;

  const EditMealLogPage({
    super.key,
    required this.mealLog,
  });

  @override
  ConsumerState<EditMealLogPage> createState() => _EditMealLogPageState();
}

class _EditMealLogPageState extends ConsumerState<EditMealLogPage> {
  late TextEditingController _mealNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  late String _selectedMealType;
  late String _selectedUnit;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _units = ['grams', 'ml', 'pieces', 'oz', 'cups', 'tbsp', 'servings'];

  @override
  void initState() {
    super.initState();
    _mealNameController = TextEditingController(text: widget.mealLog.mealName);
    _caloriesController =
        TextEditingController(text: widget.mealLog.calories.toString());
    _proteinController =
        TextEditingController(text: widget.mealLog.protein.toString());
    _carbsController = TextEditingController(text: widget.mealLog.carbs.toString());
    _fatsController = TextEditingController(text: widget.mealLog.fats.toString());
    _quantityController =
        TextEditingController(text: widget.mealLog.quantity.toString());
    _notesController =
        TextEditingController(text: widget.mealLog.notes ?? '');

    _selectedMealType = widget.mealLog.mealType.isNotEmpty 
        ? widget.mealLog.mealType[0].toUpperCase() + widget.mealLog.mealType.substring(1)
        : 'Breakfast';
    
    // Fallback to 'grams' if unit is not in list
    _selectedUnit = _units.contains(widget.mealLog.unit) 
        ? widget.mealLog.unit 
        : 'grams';
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Edit Meal',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Type Selection
              _buildSectionTitle('Meal Type'),
              _buildMealTypeSelector(),
              const SizedBox(height: 24),

              // Meal Name
              _buildSectionTitle('Meal Name *'),
              _buildTextField(
                controller: _mealNameController,
                hintText: 'e.g., Grilled Chicken with Rice',
                icon: Icons.restaurant,
              ),
              const SizedBox(height: 20),

              // Quantity and Unit
              _buildSectionTitle('Quantity & Unit'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _quantityController,
                      hintText: 'Quantity',
                      keyboardType: TextInputType.number,
                      icon: Icons.scale,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildUnitDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nutritional Information
              _buildSectionTitle('Nutritional Information (per serving)'),
              _buildNutritionFields(),
              const SizedBox(height: 24),

              // Notes
              _buildSectionTitle('Notes (Optional)'),
              _buildTextField(
                controller: _notesController,
                hintText: 'Add any notes about this meal...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateMealLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Update Meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete Meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFFF9800)) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final mealType in _mealTypes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(mealType),
                selected: _selectedMealType == mealType,
                onSelected: (selected) {
                  setState(() => _selectedMealType = mealType);
                },
                selectedColor: const Color(0xFFFF9800),
                labelStyle: TextStyle(
                  color: _selectedMealType == mealType ? Colors.white : const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: _selectedMealType == mealType
                      ? const Color(0xFFFF9800)
                      : Colors.grey[300]!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButton<String>(
        value: _selectedUnit,
        isExpanded: true,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemHeight: 48,
        items: _units.map((unit) {
          return DropdownMenuItem(
            value: unit,
            child: Text(unit),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedUnit = value ?? 'grams');
        },
      ),
    );
  }

  Widget _buildNutritionFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calories',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _caloriesController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    icon: Icons.local_fire_department,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protein (g)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _proteinController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    icon: Icons.egg,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carbs (g)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _carbsController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    icon: Icons.grain,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fats (g)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _fatsController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    icon: Icons.opacity,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateMealLog() async {
    if (_mealNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a meal name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Convert meal type to lowercase
    final mealTypeInput = _selectedMealType.toLowerCase();

    final updatedMealLog = widget.mealLog.copyWith(
      mealName: _mealNameController.text,
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fats: double.tryParse(_fatsController.text) ?? 0,
      mealType: mealTypeInput,
      quantity: double.tryParse(_quantityController.text) ?? 1,
      unit: _selectedUnit,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    // Update local state immediately
    ref.read(mealLogsProvider.notifier).updateMealLog(updatedMealLog);

    // Show loading message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating meal...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // Update to backend asynchronously
    Future.microtask(() async {
      try {
        final service = ref.read(mealLogServiceProvider);
        await service.updateMealLog(widget.mealLog.id, updatedMealLog);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back
          Navigator.pop(context);
        }
      } catch (e) {
        // Rollback local state on error
        ref.read(mealLogsProvider.notifier).updateMealLog(widget.mealLog);

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating meal: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(context);

              // Delete from local state immediately
              ref.read(mealLogsProvider.notifier).deleteMealLog(widget.mealLog.id);

              // Show deleting message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting meal...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }

              // Delete from backend asynchronously
              Future.microtask(() async {
                try {
                  final service = ref.read(mealLogServiceProvider);
                  await service.deleteMealLog(widget.mealLog.id);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meal deleted successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Navigate back to meal logging page
                    Navigator.pop(context);
                  }
                } catch (e) {
                  // Rollback local state on error
                  ref.read(mealLogsProvider.notifier).addMealLog(widget.mealLog);

                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting meal: ${e.toString()}'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  print('Error deleting meal log: $e');
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
