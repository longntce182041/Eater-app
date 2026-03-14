import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../data/consultation_api_client.dart';
import '../../data/consultation_models.dart';
import '../providers/consultation_provider.dart';

class NewConsultationPage extends ConsumerStatefulWidget {
  const NewConsultationPage({super.key});

  @override
  ConsumerState<NewConsultationPage> createState() =>
      _NewConsultationPageState();
}

class _NewConsultationPageState extends ConsumerState<NewConsultationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  ConsultationCategory _selectedCategory = ConsultationCategory.diet;
  String? _selectedNutritionistId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final api = ref.read(consultationApiClientProvider);
      await api.createConsultation(CreateConsultationDto(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        category: _selectedCategory,
        nutritionistId: _selectedNutritionistId,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation request submitted!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionistsAsync = ref.watch(nutritionistsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'New Consultation',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: 'Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration:
                    _inputDecoration('Brief description of your question'),
                maxLength: 200,
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Title must be at least 3 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<ConsultationCategory>(
                initialValue: _selectedCategory,
                decoration: _inputDecoration(null),
                items: ConsultationCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _selectedCategory = v;
                },
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Your Question'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                decoration: _inputDecoration(
                    'Describe your nutritional question in detail...'),
                maxLines: 5,
                maxLength: 2000,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Please describe your question (min 10 characters)'
                    : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                  label: 'Nutritionist (optional)',
                  subtitle: 'Leave blank to let us assign'),
              const SizedBox(height: 8),
              nutritionistsAsync.when(
                loading: () =>
                    const LinearProgressIndicator(color: AppColors.primary),
                error: (_, __) => Text(
                  'Could not load nutritionists. Request will be auto-assigned.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                data: (nutritionists) => DropdownButtonFormField<String?>(
                  initialValue: _selectedNutritionistId,
                  decoration: _inputDecoration('Any available nutritionist'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Any available nutritionist'),
                    ),
                    ...nutritionists.map((n) => DropdownMenuItem<String?>(
                          value: n.id,
                          child: Text('${n.fullName} — ${n.specialization}'),
                        )),
                  ],
                  onChanged: (v) => _selectedNutritionistId = v,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0DDD5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0DDD5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      counterStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.subtitle});

  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
