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
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                ref.read(profileNotifierProvider.notifier).toggleEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                child: ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Save Changes'),
                ),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initial,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initial,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
    );
  }
}
