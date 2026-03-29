import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cooking_provider.dart';
import '../../domain/cooking_models.dart';

/// 👨‍🍳 INTERACTIVE COOKING MODE SCREEN
///
/// Full-screen UI for guiding users through recipe cooking with:
/// - Clear step instructions (large, readable text)
/// - Step-by-step ingredients specific to current step
/// - Pro tips for the current step
/// - Progress indicator (step count + percentage bar)
/// - Next/Previous navigation buttons
/// - Finish button when all steps completed
///
/// User Experience:
/// 1. User taps recipe → CookingModeScreen opens
/// 2. Screen fetches recipe details and creates cooking session
/// 3. Shows current step (1/5) with instruction, ingredients, tips
/// 4. User performs action, taps "Next Step"
/// 5. Step marked complete in backend
/// 6. Screen advances to next step automatically
/// 7. When on last step, "Next" button changes to "Finish"
/// 8. Final "Finish" completes session
///
/// State Management:
/// - Watches cookingModeProvider for session state
/// - Reads cookingModeProvider.notifier for action methods
/// - Rebuilds when state changes
///
/// Architecture:
/// - Main build() returns ScaffoldUI structure
/// - Subfunctions: _buildCurrentStep, _buildIngredientsSection, _buildTipsSection, _buildActionButtons
/// - Separates concerns (UI structure vs content display)
class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final int servings;

  const CookingModeScreen({
    super.key,
    required this.recipeId,
    this.servings = 1,
  });

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  /// 🚀 Initialize Cooking Session
  ///
  /// Called after first frame to ensure widget is mounted
  /// Pattern: WidgetsBinding.addPostFrameCallback ensures timing is correct
  ///
  /// Steps:
  /// 1. Wait for first frame (widget tree built and ready)
  /// 2. Call ref.read(notifier).startCooking()
  /// 3. Backend initializes session and returns CookingModeData
  /// 4. Screen rebuilds automatically via provider watch
  /// 5. UI shows current step, ingredients, tips
  ///
  /// Why post-frame?
  /// - Ensures ref is properly initialized
  /// - Avoids race condition with widget initialization
  /// - Allows proper error handling via state updates
  @override
  void initState() {
    super.initState();
    // Start cooking session on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cookingModeProvider.notifier).startCooking(
            recipeId: widget.recipeId,
            servings: widget.servings,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 🏗️ Build Main Cooking UI
    ///
    /// Structure:
    /// ```
    /// Scaffold
    ///   ├─ AppBar: Recipe name
    ///   ├─ Body:
    ///   │  ├─ LinearProgressIndicator (progress bar)
    ///   │  ├─ Progress text ("Step 2 of 5", "40% done")
    ///   │  ├─ SingleChildScrollView (scrollable content)
    ///   │  │  ├─ Current step (instruction + time)
    ///   │  │  ├─ Ingredients for this step
    ///   │  │  ├─ Pro tips
    ///   │  │  └─ Spacing
    ///   │  └─ Previous/Next buttons
    /// ```
    ///
    /// State Handling:
    /// 1. isLoading: Show spinner while fetching
    /// 2. error: Show error message + back button
    /// 3. data == null: Show "No data"
    /// 4. data exists: Show full UI
    ///
    /// Watch Flow:
    /// - ref.watch(cookingModeProvider) triggers rebuild when state changes
    /// - Shows new step when session.currentStepIndex incremented
    /// - Updates progress bar in real-time
    final cookingState = ref.watch(cookingModeProvider);

    // ⏳ Loading State
    /// Show spinner while initializing cooking session
    /// Prevents UI rendering before kitchen data loaded
    if (cookingState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Starting Cooking...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ❌ Error State
    /// Display error message and back button
    /// Used if session fails to start
    if (cookingState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(cookingState.error ?? 'Unknown error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // 🔍 Null Check
    /// Guard against null data (shouldn't happen with proper error handling)
    final data = cookingState.data;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cooking')),
        body: const Center(child: Text('No data')),
      );
    }

    /// ✅ Success State - Full UI
    /// Data loaded, display cooking mode interface
    return Scaffold(
      appBar: AppBar(
        title: Text(data.recipe.name),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 📊 Progress Bar
          /// Visual indicator of cooking progress
          /// value: 0.0 to 1.0 (0% to 100%)
          /// Example: 2/5 steps = 0.4 = 40%
          LinearProgressIndicator(
            value: data.progressPercentage / 100,
            minHeight: 4,
          ),

          // 📍 Step Counter and Percentage
          /// Shows which step the user is on and overall progress
          /// Example: "Step 2 of 5", "40% done"
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${data.session.currentStepIndex + 1} of ${data.totalSteps}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${(data.progressPercentage).toStringAsFixed(0)}% done'),
              ],
            ),
          ),

          // 📖 Main Content (Scrollable)
          /// Display current step instruction, ingredients, and tips
          /// Wrapped in SingleChildScrollView for long instructions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentStep(data),
                  const SizedBox(height: 32),
                  _buildIngredientsSection(data),
                  const SizedBox(height: 32),
                  _buildTipsSection(data),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 🔘 Action Buttons
          /// Previous/Next buttons for navigation
          /// Last step shows "Finish" instead of "Next"
          _buildActionButtons(context, data),
        ],
      ),
    );
  }

  /// 🎯 Build Current Step Display
  ///
  /// Shows:
  /// - Large, readable instruction text
  /// - Step number badge (orange background)
  /// - Estimated time with icon
  ///
  /// Styling:
  /// - Orange container (#FFF3E0 background, border)
  /// - Large text (18pt, bold, line-height 1.5 for readability)
  /// - Time display with clock icon
  ///
  /// Example Output:
  /// ```
  /// ╔════════════════════════════════════════╗
  /// ║ ┌────┐                                  ║
  /// ║ │ 1  │ Step Number                      ║
  /// ║ └────┘                                  ║
  /// ║                                         ║
  /// ║ Mix dry ingredients together in a     ║
  /// ║ bowl. Add flour, sugar, and baking    ║
  /// ║ powder. Whisk well.                    ║
  /// ║                                         ║
  /// ║ ⏱ ~5 min                                ║
  /// ╚════════════════════════════════════════╝
  /// ```
  Widget _buildCurrentStep(CookingModeData data) {
    final step = data.currentStep;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Step ${step.stepNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.instruction,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          if (step.estimatedTime > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text('~${step.estimatedTime ~/ 60} min'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 🥘 Build Ingredients Section
  ///
  /// Displays ingredients needed for current step
  /// Each ingredient shows quantity + name
  ///
  /// Example:
  /// ```
  /// Ingredients for this step
  /// • 2 cups all-purpose flour
  /// • 1 cup sugar
  /// • 0.5 tsp salt
  /// ```
  ///
  /// Hides section if step has no ingredients (returns empty SizedBox)
  ///
  /// Quantities:
  /// - Already scaled by backend for requested servings
  /// - Uses StepIngredient.displayQuantity() for formatting
  Widget _buildIngredientsSection(CookingModeData data) {
    final step = data.currentStep;
    if (step.ingredients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients for this step',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: step.ingredients
                .map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${ingredient.displayQuantity()} ${ingredient.name}',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// 💡 Build Pro Tips Section
  ///
  /// Displays helpful hints for the current step
  /// Styled with blue background and lightbulb icon
  ///
  /// Example:
  /// ```
  /// 💡 Pro Tip
  /// Use medium heat for even cooking. Stir
  /// frequently to prevent burning.
  /// ```
  ///
  /// Hides if step has no tips
  Widget _buildTipsSection(CookingModeData data) {
    final step = data.currentStep;
    if (step.tips.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB3D9FF)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: Color(0xFF1976D2)),
              const SizedBox(width: 8),
              const Text(
                'Pro Tip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.tips,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }

  /// 🔘 Build Action Buttons
  ///
  /// Shows Previous/Next navigation and completion
  ///
  /// Logic:
  /// - First step: No "Previous" button
  /// - Middle steps: Both "Previous" and "Next" buttons
  /// - Last step: "Next" changes to "Finish" button
  ///
  /// Button Actions:
  /// - Previous: Placeholder (currently just shows snackbar)
  /// - Next: Calls completeStep() → advances to next
  /// - Finish: Calls finishCooking() → completes session → pops screen
  ///
  /// Styling:
  /// - Orange button ({0xFFFF9800) with white text
  /// - OutlinedButton for Previous
  /// - Full-width Expanded button
  /// - Safe space for notch/rounded corners (padding.bottom)
  ///
  /// Example Progression:
  /// Step 1/5: [Next Step]
  /// Step 2/5: [Previous] [Next Step]
  /// Step 5/5: [Previous] [Finish]
  Widget _buildActionButtons(BuildContext context, CookingModeData data) {
    final isLastStep = data.session.currentStepIndex == data.totalSteps - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // ⬅️ Previous Button
          /// Only shown if not on first step
          /// Placeholder implementation (should navigate backward)
          if (data.session.currentStepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Going to previous step...')),
                  );
                },
                child: const Text('Previous'),
              ),
            ),
          if (data.session.currentStepIndex > 0) const SizedBox(width: 12),

          // ➡️ Next/Finish Button
          /// Changes label based on progress
          /// - "Next Step" for normal progression
          /// - "Finish" on last step
          ///
          /// Action:
          /// - Next Step: Call completeStep() → API marks complete →
          ///   refreshSession() → currentStepIndex++ → UI advances
          /// - Finish: Call finishCooking() → API marks completed →
          ///   Pop screen
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (isLastStep) {
                  // Finish cooking
                  await ref.read(cookingModeProvider.notifier).finishCooking();
                  if (mounted && context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  // Next step
                  await ref
                      .read(cookingModeProvider.notifier)
                      .completeStep(
                        stepNumber: data.session.currentStepIndex + 1,
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
              child: Text(
                isLastStep ? 'Finish' : 'Next Step',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
