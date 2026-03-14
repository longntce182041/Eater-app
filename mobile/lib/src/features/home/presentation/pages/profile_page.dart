import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_provider.dart';
import '../../domain/profile_models.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2D2D2D)),
            onPressed: () =>
                ref.read(profileNotifierProvider.notifier).toggleEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2D2D2D)),
            onPressed: () => _handleLogout(context, ref),
          ),
        ],
      ),
      body: state.profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => _ProfileContent(
          data: data,
          isEditing: state.isEditing,
          onSave: (updates) => ref
              .read(profileNotifierProvider.notifier)
              .saveUpdates(updates: updates),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      context.go('/sign-in');
    }
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final ProfileCombinedData data;
  final bool isEditing;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _ProfileContent({
    required this.data,
    required this.isEditing,
    required this.onSave,
  });

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  final _formKey = GlobalKey<FormState>();

  late String? firstName = widget.data.profile.firstName ?? '';
  late String? lastName = widget.data.profile.lastName ?? '';
  late String? phoneNumber = widget.data.profile.phoneNumber ?? '';
  late int age = widget.data.profile.age;
  late String gender = widget.data.profile.gender;
  late double height = widget.data.profile.height;
  late double weight = widget.data.profile.weight;
  late double? goalWeight = widget.data.profile.goalWeight;
  late String? healthGoals = widget.data.profile.healthGoals ?? '';

  late String? dietTypeId = widget.data.dietary?.dietType?.id;
  late String activityLevel = widget.data.dietary?.activityLevel ?? 'sedentary';
  late String cookingSkillLevel =
      widget.data.dietary?.cookingSkillLevel ?? 'beginner';
  late int availableCookingTime =
      widget.data.dietary?.availableCookingTime ?? 30;
  late int dailyCalorieTarget = widget.data.dietary?.dailyCalorieTarget ?? 2000;
  late String allergiesText = (widget.data.dietary?.allergies ?? []).join(', ');
  late String dislikesText =
      (widget.data.dietary?.dislikesIngredients ?? []).join(', ');

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            _textField(
              'First Name',
              firstName ?? '',
              enabled: isEditing,
              onChanged: (v) => setState(() => firstName = v),
            ),
            _textField(
              'Last Name',
              lastName ?? '',
              enabled: isEditing,
              onChanged: (v) => setState(() => lastName = v),
            ),
            _textField(
              'Phone Number',
              phoneNumber ?? '',
              enabled: isEditing,
              onChanged: (v) => setState(() => phoneNumber = v),
            ),
            _numberField(
              'Age',
              age.toString(),
              enabled: isEditing,
              onChanged: (v) => setState(() => age = int.tryParse(v) ?? age),
            ),
            _dropdownField(
              'Gender',
              gender,
              ['male', 'female', 'other'],
              enabled: isEditing,
              onChanged: (v) => setState(() => gender = v!),
            ),
            _numberField(
              'Height (cm)',
              height.toString(),
              enabled: isEditing,
              onChanged: (v) =>
                  setState(() => height = double.tryParse(v) ?? height),
            ),
            _numberField(
              'Weight (kg)',
              weight.toString(),
              enabled: isEditing,
              onChanged: (v) =>
                  setState(() => weight = double.tryParse(v) ?? weight),
            ),
            _numberField(
              'Goal Weight (kg)',
              (goalWeight ?? '').toString(),
              enabled: isEditing,
              onChanged: (v) => setState(() => goalWeight = double.tryParse(v)),
            ),
            _textField(
              'Health Goals',
              healthGoals ?? '',
              enabled: isEditing,
              onChanged: (v) => setState(() => healthGoals = v),
            ),
            const SizedBox(height: 24),
            if (widget.data.healthMetrics != null)
              _HealthMetricsSection(metrics: widget.data.healthMetrics!),
            const SizedBox(height: 24),
            const Text(
              'Dietary References',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            _DietTypeDropdown(
              value: dietTypeId,
              enabled: widget.isEditing,
              onChanged: (v) => setState(() => dietTypeId = v),
              ref: ref,
            ),
            _dropdownField(
              'Activity Level',
              activityLevel,
              ['sedentary', 'light', 'moderate', 'active', 'very active'],
              enabled: isEditing,
              onChanged: (v) => setState(() => activityLevel = v!),
            ),
            _dropdownField(
              'Cooking Skill',
              cookingSkillLevel,
              ['beginner', 'intermediate', 'advanced'],
              enabled: isEditing,
              onChanged: (v) => setState(() => cookingSkillLevel = v!),
            ),
            _numberField(
              'Available Cooking Time (min)',
              availableCookingTime.toString(),
              enabled: isEditing,
              onChanged: (v) => availableCookingTime =
                  int.tryParse(v) ?? availableCookingTime,
            ),
            _numberField(
              'Daily Calorie Target (kcal)',
              dailyCalorieTarget.toString(),
              enabled: isEditing,
              onChanged: (v) =>
                  dailyCalorieTarget = int.tryParse(v) ?? dailyCalorieTarget,
            ),
            _textField(
              'Allergies (comma-separated)',
              allergiesText,
              enabled: isEditing,
              onChanged: (v) => setState(() => allergiesText = v),
            ),
            _textField(
              'Dislikes (comma-separated)',
              dislikesText,
              enabled: isEditing,
              onChanged: (v) => setState(() => dislikesText = v),
            ),
            const SizedBox(height: 24),

            // Settings section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/reminders'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alarm_outlined,
                          color: Color(0xFFFF9800), size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meal Reminders',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Set daily meal time notifications',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF666666)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (isEditing)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final allergies = allergiesText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final dislikes = dislikesText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updates = <String, dynamic>{
      'firstName': firstName?.isNotEmpty == true ? firstName : '',
      'lastName': lastName?.isNotEmpty == true ? lastName : '',
      'phoneNumber': phoneNumber?.isNotEmpty == true ? phoneNumber : '',
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal_weight': goalWeight,
      'healthGoals': healthGoals?.isNotEmpty == true ? healthGoals : '',
      if (dietTypeId != null && dietTypeId!.isNotEmpty)
        'diet_typeId': dietTypeId,
      'activityLevel': activityLevel,
      'cookingSkillLevel': cookingSkillLevel,
      'available_cooking_time': availableCookingTime,
      'daily_calorie_target': dailyCalorieTarget,
      'allergies': allergies,
      'dislikesIngredients': dislikes,
    };

    widget.onSave(updates);
  }

  Widget _textField(
    String label,
    String initial, {
    required bool enabled,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initial,
        enabled: enabled,
        style: const TextStyle(color: Color(0xFF000000)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF000000)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _numberField(
    String label,
    String initial, {
    required bool enabled,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initial,
        enabled: enabled,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFF000000)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF000000)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdownField(
    String label,
    String value,
    List<String> options, {
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF000000)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(color: Color(0xFF000000)),
              items: options
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Color(0xFF000000)),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthMetricsSection extends StatelessWidget {
  final HealthMetricsModel metrics;

  const _HealthMetricsSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE0CC), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricRow('BMI', metrics.bmi.toStringAsFixed(1), 'kg/m²'),
              const SizedBox(height: 12),
              _MetricRow('BMR', metrics.bmr.toStringAsFixed(0), 'kcal/day'),
              const SizedBox(height: 12),
              _MetricRow('TDEE', metrics.tdee.toStringAsFixed(0), 'kcal/day'),
              const SizedBox(height: 12),
              _MetricRow('Body Category', metrics.bodyCategory, ''),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MetricRow(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DietTypeDropdown extends ConsumerWidget {
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final WidgetRef ref;

  const _DietTypeDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dietTypesAsync = ref.watch(dietTypesProvider);

    return dietTypesAsync.when(
      loading: () => _buildDropdownField(
        'Diet Type',
        value,
        [],
        enabled: false,
        onChanged: onChanged,
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Error loading diet types: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (dietTypes) => _buildDropdownField(
        'Diet Type',
        value,
        dietTypes.map((dt) => dt.id).toList(),
        enabled: enabled,
        onChanged: onChanged,
        dietTypeLabels: {for (var dt in dietTypes) dt.id: dt.name},
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options, {
    required bool enabled,
    required ValueChanged<String?> onChanged,
    Map<String, String>? dietTypeLabels,
  }) {
    // Validate that value exists in options, otherwise use null
    final validValue =
        (value?.isNotEmpty ?? false) && options.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF000000)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: validValue,
              isExpanded: true,
              style: const TextStyle(color: Color(0xFF000000)),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Select Diet Type',
                    style: TextStyle(color: Color(0xFF000000)),
                  ),
                ),
                ...options.map((id) {
                  final label = dietTypeLabels?[id] ?? id;
                  return DropdownMenuItem<String?>(
                    value: id,
                    child: Text(
                      label,
                      style: const TextStyle(color: Color(0xFF000000)),
                    ),
                  );
                }),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ),
    );
  }
}
