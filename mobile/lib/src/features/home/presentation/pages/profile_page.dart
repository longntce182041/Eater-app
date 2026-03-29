import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../pro/data/pro_api_client.dart';
import '../providers/profile_provider.dart';
import '../../domain/profile_models.dart';
import '../../../health_guides/presentation/pages/health_guides_screen.dart';

// Validation constants matching backend
const validationRules = {
  'nameMax': 50,
  'phoneMax': 20,
  'healthGoalsMax': 500,
  'ageMin': 1,
  'ageMax': 150,
  'genders': ['male', 'female', 'other'],
  'activityLevels': ['sedentary', 'light', 'moderate', 'active', 'very active'],
  'cookingSkills': ['beginner', 'intermediate', 'advanced'],
};
// Fix Standardizae User Profile Page
// - Ensure all fields have proper validation and error handling

final profileProStatusProvider = FutureProvider<ProStatusModel>((ref) async {
  final api = ref.watch(proApiClientProvider);
  try {
    return await api.getStatus();
  } catch (_) {
    return const ProStatusModel(isPro: false);
  }
});

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
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
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
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (context.mounted) {
          context.go('/sign-in');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _goalWeightCtrl;
  late TextEditingController _healthGoalsCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _dislikesCtrl;
  late TextEditingController _cookingTimeCtrl;
  late TextEditingController _calorieTargetCtrl;

  late String gender;
  late String activityLevel;
  late String cookingSkillLevel;
  late String? dietTypeId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = widget.data.profile;
    final dietary = widget.data.dietary;

    _firstNameCtrl = TextEditingController(text: profile.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: profile.lastName ?? '');
    _phoneCtrl = TextEditingController(text: profile.phoneNumber ?? '');
    _ageCtrl = TextEditingController(text: profile.age.toString());
    _heightCtrl = TextEditingController(text: profile.height.toString());
    _weightCtrl = TextEditingController(text: profile.weight.toString());
    _goalWeightCtrl =
        TextEditingController(text: profile.goalWeight?.toString() ?? '');
    _healthGoalsCtrl = TextEditingController(text: profile.healthGoals ?? '');
    _allergiesCtrl =
        TextEditingController(text: (dietary?.allergies ?? []).join(', '));
    _dislikesCtrl = TextEditingController(
        text: (dietary?.dislikesIngredients ?? []).join(', '));
    _cookingTimeCtrl = TextEditingController(
        text: (dietary?.availableCookingTime ?? 30).toString());
    _calorieTargetCtrl = TextEditingController(
        text: (dietary?.dailyCalorieTarget ?? 2000).toString());

    gender = profile.gender;
    activityLevel = dietary?.activityLevel ?? 'sedentary';
    cookingSkillLevel = dietary?.cookingSkillLevel ?? 'beginner';
    dietTypeId = dietary?.dietType?.id;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _goalWeightCtrl.dispose();
    _healthGoalsCtrl.dispose();
    _allergiesCtrl.dispose();
    _dislikesCtrl.dispose();
    _cookingTimeCtrl.dispose();
    _calorieTargetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final proStatusAsync = ref.watch(profileProStatusProvider);
    final isPro = proStatusAsync.asData?.value.isPro == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Profile Section
            _buildSectionHeader('Basic Information'),
            _buildTextField(
              'First Name',
              _firstNameCtrl,
              enabled: isEditing,
              validator: (val) {
                if (val != null && val.length > 50) {
                  return 'First name max 50 characters';
                }
                return null;
              },
            ),
            _buildTextField(
              'Last Name',
              _lastNameCtrl,
              enabled: isEditing,
              validator: (val) {
                if (val != null && val.length > 50) {
                  return 'Last name max 50 characters';
                }
                return null;
              },
            ),
            _buildTextField(
              'Phone Number',
              _phoneCtrl,
              enabled: isEditing,
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  if (!RegExp(r'^[0-9+\-()\s]*$').hasMatch(val)) {
                    return 'Invalid phone format';
                  }
                  if (val.length > 20) {
                    return 'Phone max 20 characters';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Health Information Section
            _buildSectionHeader('Health Information'),
            _buildTextField(
              'Age *',
              _ageCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(val);
                if (age == null) {
                  return 'Age must be a number';
                }
                if (age < 1 || age > 150) {
                  return 'Age must be between 1 and 150';
                }
                return null;
              },
            ),
            _buildDropdownField(
              'Gender *',
              gender,
              validationRules['genders'] as List<String>,
              enabled: isEditing,
              onChanged: (val) => setState(() => gender = val!),
            ),
            _buildTextField(
              'Height (cm) *',
              _heightCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Height is required';
                }
                final height = double.tryParse(val);
                if (height == null || height <= 0) {
                  return 'Height must be greater than 0';
                }
                return null;
              },
            ),
            _buildTextField(
              'Weight (kg) *',
              _weightCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Weight is required';
                }
                final weight = double.tryParse(val);
                if (weight == null || weight <= 0) {
                  return 'Weight must be greater than 0';
                }
                return null;
              },
            ),
            _buildTextField(
              'Goal Weight (kg)',
              _goalWeightCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  final weight = double.tryParse(val);
                  if (weight == null || weight <= 0) {
                    return 'Goal weight must be greater than 0';
                  }
                }
                return null;
              },
            ),
            _buildTextField(
              'Health Goals',
              _healthGoalsCtrl,
              enabled: isEditing,
              maxLines: 3,
              validator: (val) {
                if (val != null && val.length > 500) {
                  return 'Health goals max 500 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Health Metrics Section
            if (widget.data.healthMetrics != null)
              _HealthMetricsSection(metrics: widget.data.healthMetrics!),
            const SizedBox(height: 24),

            // Dietary Preferences Section
            _buildSectionHeader('Dietary Preferences'),
            _buildTextField(
              'Allergies (comma-separated)',
              _allergiesCtrl,
              enabled: isEditing,
              maxLines: 2,
            ),
            _buildTextField(
              'Dislikes (comma-separated)',
              _dislikesCtrl,
              enabled: isEditing,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Activity & Cooking Section
            _buildSectionHeader('Activity & Cooking'),
            _buildDropdownField(
              'Activity Level *',
              activityLevel,
              validationRules['activityLevels'] as List<String>,
              enabled: isEditing,
              onChanged: (val) => setState(() => activityLevel = val!),
            ),
            _buildDropdownField(
              'Cooking Skill *',
              cookingSkillLevel,
              validationRules['cookingSkills'] as List<String>,
              enabled: isEditing,
              onChanged: (val) => setState(() => cookingSkillLevel = val!),
            ),
            _buildTextField(
              'Available Cooking Time (minutes)',
              _cookingTimeCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  final time = int.tryParse(val);
                  if (time == null || time < 0) {
                    return 'Cooking time must be 0 or greater';
                  }
                }
                return null;
              },
            ),
            _buildTextField(
              'Daily Calorie Target',
              _calorieTargetCtrl,
              enabled: isEditing,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  final cal = int.tryParse(val);
                  if (cal == null || cal < 0) {
                    return 'Calorie target must be 0 or greater';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader('Settings'),
            _buildSettingsTile(
              icon: Icons.alarm_outlined,
              iconColor: const Color(0xFFFF9800),
              iconBgColor: const Color(0xFFFFF3E0),
              title: 'Meal Reminders',
              subtitle: 'Set daily meal time notifications',
              onTap: () => context.push('/reminders'),
            ),
            _buildSettingsTile(
              icon:
                  isPro ? Icons.medical_services_outlined : Icons.lock_outline,
              iconColor: const Color(0xFF2E7D32),
              iconBgColor: const Color(0xFFE8F5E9),
              title: 'Nutritionist Consultation',
              subtitle: isPro
                  ? 'Consult with verified nutritionists'
                  : 'Pro required - tap to upgrade',
              onTap: () {
                if (!isPro) {
                  context.push('/pro-upgrade');
                } else {
                  context.push('/nutritionists');
                }
              },
              hasBadge: !isPro,
            ),
            _buildSettingsTile(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF1976D2),
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'Health & Lifestyle Guides',
              subtitle: 'Learn about fasting, workouts, and healthy habits',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const HealthGuidesScreen(),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.workspace_premium_outlined,
              iconColor: const Color(0xFFFFB300),
              iconBgColor: const Color(0xFFFFF8E1),
              title: 'Upgrade to Pro',
              subtitle: 'Unlock premium meal planning features',
              onTap: () => context.push('/pro-upgrade'),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isEditing) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _handleCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D2D2D),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Color(0xFF000000), fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 12),
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2D2D2D), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options, {
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 12),
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            style: const TextStyle(color: Color(0xFF000000), fontSize: 14),
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Color(0xFF999999)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final allergies = _allergiesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final dislikes = _dislikesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updates = <String, dynamic>{
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'age': int.parse(_ageCtrl.text),
      'gender': gender,
      'height': double.parse(_heightCtrl.text),
      'weight': double.parse(_weightCtrl.text),
      if (_goalWeightCtrl.text.isNotEmpty)
        'goalWeight': double.parse(_goalWeightCtrl.text),
      'healthGoals': _healthGoalsCtrl.text.trim(),
      'activityLevel': activityLevel,
      'cookingSkillLevel': cookingSkillLevel,
      'availableCookingTime': int.parse(_cookingTimeCtrl.text),
      'dailyCalorieTarget': int.parse(_calorieTargetCtrl.text),
      if (allergies.isNotEmpty) 'allergies': allergies,
      if (dislikes.isNotEmpty) 'dislikesIngredients': dislikes,
    };

    widget.onSave(updates);
  }

  void _handleCancel() {
    _initializeControllers();
    ref.read(profileNotifierProvider.notifier).toggleEdit(false);
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE0CC), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MetricRow('BMI', metrics.bmi.toStringAsFixed(1), 'kg/m²'),
              const Divider(height: 16),
              _MetricRow('BMR', metrics.bmr.toStringAsFixed(0), 'kcal/day'),
              const Divider(height: 16),
              _MetricRow('TDEE', metrics.tdee.toStringAsFixed(0), 'kcal/day'),
              const Divider(height: 16),
              _MetricRow('Body Category', metrics.bodyCategory, ''),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
