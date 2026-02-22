import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_setup_provider.dart';

// State management for age selection
class AgeState {
  final int selectedAge;

  AgeState({required this.selectedAge});

  AgeState copyWith({int? selectedAge}) {
    return AgeState(selectedAge: selectedAge ?? this.selectedAge);
  }
}

// StateNotifier for managing age state
class AgeNotifier extends StateNotifier<AgeState> {
  AgeNotifier() : super(AgeState(selectedAge: 26));

  void updateAge(int age) {
    if (age >= 18 && age <= 80) {
      state = state.copyWith(selectedAge: age);
    }
  }
}

// Provider for age state
final ageProvider = StateNotifierProvider<AgeNotifier, AgeState>((ref) {
  return AgeNotifier();
});

class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialAge = ref.read(ageProvider).selectedAge;
    _scrollController = FixedExtentScrollController(
      initialItem: initialAge - 18, // 18 is the minimum age
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    final controller = TextEditingController(
      text: ref.read(ageProvider).selectedAge.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your age',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Color(0xFF000000)),
              decoration: InputDecoration(
                hintText: 'Age (18-80)',
                hintStyle: const TextStyle(color: Color(0xFF000000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final age = int.tryParse(controller.text);
                  if (age != null && age >= 18 && age <= 80) {
                    ref.read(ageProvider.notifier).updateAge(age);
                    _scrollController.animateToItem(
                      age - 18,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid age (18-80)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    final selectedAge = ref.read(ageProvider).selectedAge;

    // Save age to shared profile state
    final userId = ref.read(profileSetupProvider('')).data.userId ?? '';
    ref.read(profileSetupProvider(userId).notifier).setAge(selectedAge);

    // Navigate to next page (height)
    if (!mounted) return;
    context.push('/set-height');
  }

  @override
  Widget build(BuildContext context) {
    final ageState = ref.watch(ageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // Light beige
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How old are you?',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                // Age wheel picker
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The white pill background for selected item
                          Container(
                            height: 60,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          // The wheel scroll view
                          ListWheelScrollView.useDelegate(
                            controller: _scrollController,
                            itemExtent: 60,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              ref
                                  .read(ageProvider.notifier)
                                  .updateAge(index + 18);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 63, // 18 to 80
                              builder: (context, index) {
                                final age = index + 18;
                                final isSelected = age == ageState.selectedAge;
                                final distance = (age - ageState.selectedAge)
                                    .abs();

                                // Calculate opacity based on distance
                                double opacity = 1.0;
                                if (distance == 1) {
                                  opacity = 0.5;
                                } else if (distance == 2) {
                                  opacity = 0.3;
                                } else if (distance > 2) {
                                  opacity = 0.15;
                                }

                                return Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Opacity(
                                        opacity: opacity,
                                        child: Text(
                                          age.toString(),
                                          style: TextStyle(
                                            fontSize: isSelected ? 32 : 28,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: const Color(0xFF2D2D2D),
                                          ),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: _showEditDialog,
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Continue button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
