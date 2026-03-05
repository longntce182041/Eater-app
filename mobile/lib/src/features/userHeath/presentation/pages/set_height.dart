import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_setup_provider.dart';
import '../../../../core/utils/notification_service.dart';

// Local state for height selection
class HeightState {
  final int selectedHeight;

  HeightState({required this.selectedHeight});

  HeightState copyWith({int? selectedHeight}) {
    return HeightState(selectedHeight: selectedHeight ?? this.selectedHeight);
  }
}

class HeightNotifier extends StateNotifier<HeightState> {
  HeightNotifier() : super(HeightState(selectedHeight: 170));

  void updateHeight(int height) {
    if (height >= 120 && height <= 250) {
      state = state.copyWith(selectedHeight: height);
    }
  }
}

final heightProvider = StateNotifierProvider<HeightNotifier, HeightState>((
  ref,
) {
  return HeightNotifier();
});

class SetHeightPage extends ConsumerStatefulWidget {
  const SetHeightPage({super.key});

  @override
  ConsumerState<SetHeightPage> createState() => _SetHeightPageState();
}

class _SetHeightPageState extends ConsumerState<SetHeightPage> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialHeight = ref.read(heightProvider).selectedHeight;
    _scrollController = FixedExtentScrollController(
      initialItem: initialHeight - 120, // 120 is the minimum height
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    final controller = TextEditingController(
      text: ref.read(heightProvider).selectedHeight.toString(),
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
              'Enter your height',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Color(0xFF000000)),
              decoration: InputDecoration(
                hintText: 'Height in cm (120-250)',
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
                  final height = int.tryParse(controller.text);
                  if (height != null && height >= 120 && height <= 250) {
                    ref.read(heightProvider.notifier).updateHeight(height);
                    _scrollController.animateToItem(
                      height - 120,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    Navigator.pop(context);
                  } else {
                    NotificationService.showWarning(
                      context,
                      message: 'Please enter a valid height (120-250 cm)',
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

  void _handleContinue() {
    final selectedHeight = ref.read(heightProvider).selectedHeight;
    final userId = ref.read(profileSetupProvider('')).data.userId ?? '';
    ref.read(profileSetupProvider(userId).notifier).setHeight(selectedHeight);
    context.push('/set-weight');
  }

  @override
  Widget build(BuildContext context) {
    final heightState = ref.watch(heightProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How tall are you?',
                    style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 160,
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
                      ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 60,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          ref
                              .read(heightProvider.notifier)
                              .updateHeight(index + 120);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 131, // 120 to 250
                          builder: (context, index) {
                            final height = index + 120;
                            final isSelected =
                                height == heightState.selectedHeight;
                            final distance =
                                (height - heightState.selectedHeight).abs();

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
                                      '$height cm',
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
                                        color: Color(0xFF000000),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
