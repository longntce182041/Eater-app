import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/auth_notifier.dart';
import '../../../auth/data/token_storage.dart';
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
    final tokenStorage = TokenStorage();
    await tokenStorage.clear();
    ref.read(authNotifierProvider).setAuthenticated(false);
    if (context.mounted) {
      context.go('/sign-in');
    }
  }
}

class _ProfileContent extends StatefulWidget {
  final ProfileCombinedData data;
  final bool isEditing;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _ProfileContent({
    required this.data,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _formKey = GlobalKey<FormState>();

  late String? firstName = widget.data.profile.firstName ?? '';
  late String? lastName = widget.data.profile.lastName ?? '';
  late String? phoneNumber = widget.data.profile.phoneNumber ?? '';
  late String? avatar = widget.data.profile.avatar ?? '';
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
  late String dislikesText = (widget.data.dietary?.dislikesIngredients ?? [])
      .join(', ');

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
              onChanged: (v) => firstName = v,
            ),
            _textField(
              'Last Name',
              lastName ?? '',
              enabled: isEditing,
              onChanged: (v) => lastName = v,
            ),
            _textField(
              'Phone Number',
              phoneNumber ?? '',
              enabled: isEditing,
              onChanged: (v) => phoneNumber = v,
            ),
            _textField(
              'Avatar URL',
              avatar ?? '',
              enabled: isEditing,
              onChanged: (v) => avatar = v,
            ),
            _numberField(
              'Age',
              age.toString(),
              enabled: isEditing,
              onChanged: (v) => age = int.tryParse(v) ?? age,
            ),
            _dropdownField(
              'Gender',
              gender,
              ['male', 'female', 'other'],
              enabled: isEditing,
              onChanged: (v) => gender = v!,
            ),
            _numberField(
              'Height (cm)',
              height.toString(),
              enabled: isEditing,
              onChanged: (v) => height = double.tryParse(v) ?? height,
            ),
            _numberField(
              'Weight (kg)',
              weight.toString(),
              enabled: isEditing,
              onChanged: (v) => weight = double.tryParse(v) ?? weight,
            ),
            _numberField(
              'Goal Weight (kg)',
              (goalWeight ?? '').toString(),
              enabled: isEditing,
              onChanged: (v) => goalWeight = double.tryParse(v),
            ),
            _textField(
              'Health Goals',
              healthGoals ?? '',
              enabled: isEditing,
              onChanged: (v) => healthGoals = v,
            ),
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
            _textField(
              'Diet Type Id',
              dietTypeId ?? '',
              enabled: isEditing,
              onChanged: (v) => dietTypeId = v.isEmpty ? null : v,
            ),
            _dropdownField(
              'Activity Level',
              activityLevel,
              ['sedentary', 'light', 'moderate', 'active', 'very active'],
              enabled: isEditing,
              onChanged: (v) => activityLevel = v!,
            ),
            _dropdownField(
              'Cooking Skill',
              cookingSkillLevel,
              ['beginner', 'intermediate', 'advanced'],
              enabled: isEditing,
              onChanged: (v) => cookingSkillLevel = v!,
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
              onChanged: (v) => allergiesText = v,
            ),
            _textField(
              'Dislikes (comma-separated)',
              dislikesText,
              enabled: isEditing,
              onChanged: (v) => dislikesText = v,
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
      'avatar': avatar?.isNotEmpty == true ? avatar : '',
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF000000)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ),
    );
  }
}
