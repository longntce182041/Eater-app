# Meal Logging Feature - Implementation Guide

## Overview
A complete meal logging system has been implemented in your Flutter mobile app, allowing users to:
- **Log meals** eaten during the day
- **Edit recorded meals** with updated nutritional information
- **Delete meals** with confirmation
- **Track daily nutrition** with summaries organized by meal type

## Files Created

### 1. **Meal Log Domain Entity**
📁 `lib/src/features/nutrition/domain/entities/meal_log.dart`
- Data model representing a single meal log
- Properties: mealName, calories, protein, carbs, fats, quantity, unit, mealType, loggedAt, notes
- Includes JSON serialization for API integration

### 2. **Meal Log Provider (State Management)**
📁 `lib/src/features/nutrition/presentation/providers/meal_log_provider.dart`
- Riverpod StateNotifier for managing meal logs
- **Key Providers**:
  - `mealLogsProvider` - All meal logs
  - `todayMealLogsProvider` - Today's meals
  - `todayTotalsProvider` - Daily nutritional totals

### 3. **Meal Logging Page**
📁 `lib/src/features/nutrition/presentation/pages/meal_logging_page.dart`
- Main page showing all logged meals for today
- Daily summary card displaying total calories, protein, carbs, fats
- Meals organized by type: Breakfast, Lunch, Dinner, Snack
- Edit & Delete buttons for each meal
- FAB (+) button to add new meals
- Empty state message when no meals logged

### 4. **Log Meal Page**
📁 `lib/src/features/nutrition/presentation/pages/log_meal_page.dart`
- Form to add new meal logs
- **Fields**:
  - Meal Type (Breakfast, Lunch, Dinner, Snack)
  - Meal Name
  - Quantity & Unit (grams, ml, pieces, oz, cups, tbsp)
  - Nutritional Info (Calories, Protein, Carbs, Fats)
  - Optional Notes

### 5. **Edit Meal Page**
📁 `lib/src/features/nutrition/presentation/pages/edit_meal_log_page.dart`
- Form to edit existing meals (pre-filled with current values)
- Update button to save changes
- Delete button with confirmation dialog

## Navigation Integration

### Updated: Main Navigation Page
📁 `lib/src/features/home/presentation/pages/main_navigation_page.dart`

**Bottom Navigation Tabs**:
1. **Home** - Home page (default)
2. **Meals** ✨ NEW - Meal logging page
3. **Plans** - Meal planning page
4. **Recipes** - Recipe browsing
5. **Profile** - User profile

## How to Use

### Adding a Meal
1. Tap the **Meals** icon in bottom navigation
2. Tap the blue **+** button (FAB)
3. Fill in meal details:
   - Select meal type (Breakfast/Lunch/Dinner/Snack)
   - Enter meal name
   - Set quantity and unit
   - Input nutritional values
   - Add optional notes
4. Tap **"Log Meal"**

### Editing a Meal
1. Navigate to **Meals** tab
2. Find the meal you want to edit
3. Tap the **pencil icon** on the meal card
4. Update the details
5. Tap **"Update Meal"**

### Deleting a Meal
1. Navigate to **Meals** tab
2. Tap the **trash icon** on the meal card (or delete button on edit page)
3. Confirm deletion in the dialog

### Viewing Daily Summary
- Navigate to **Meals** tab
- Scroll to the top to see the daily intake card
- Shows total Calories, Protein, Carbs, and Fats for today

## UI Design Features

### Visual Hierarchy
- **Orange Primary Color** (#FF9800) for actions and highlights
- **Cream Background** (#F5F1E8) for consistency with app theme
- **White Cards** with subtle shadows for meal items

### Interactive Elements
- FilterChips for meal type selection
- TextField inputs with orange focus states
- Dropdown for unit selection
- Icon buttons for edit/delete actions

### Organization
- Meals grouped by type (Breakfast, Lunch, Dinner, Snack)
- Each meal shows name, quantity, calories, and macros at a glance
- Daily totals prominently displayed

## Data Structure

### MealLog Object
```dart
MealLog {
  id: String,
  mealName: String,
  calories: double,
  protein: double,
  carbs: double,
  fats: double,
  mealType: String, // "Breakfast", "Lunch", "Dinner", "Snack"
  loggedAt: DateTime,
  quantity: double,
  unit: String, // "grams", "ml", "pieces", etc.
  notes: String? // Optional
}
```

## State Management

### Using Riverpod for State
- Meals stored in `mealLogsProvider` (in-memory)
- Real-time updates across all pages
- No persistence yet (can be integrated with backend API)

### Available Methods
```dart
// Add a new meal
ref.read(mealLogsProvider.notifier).addMealLog(mealLog);

// Update an existing meal
ref.read(mealLogsProvider.notifier).updateMealLog(mealLog);

// Delete a meal
ref.read(mealLogsProvider.notifier).deleteMealLog(mealLogId);

// Get today's totals
ref.watch(todayTotalsProvider);

// Get today's meals
ref.watch(todayMealLogsProvider);
```

## Future Enhancements

### Backend Integration
- Connect to API to persist meal logs
- Sync across devices
- Historical data analysis

### Features to Add
- Meal database/search functionality
- Quick-add common meals
- Barcode scanning for ingredients
- Nutritional macro visualizations
- Weekly/monthly analytics
- Meal plan integration
- Smart suggestions based on goals

## Testing

To test the meal logging feature:
1. Navigate to the **Meals** tab in the app
2. Add a test meal with the **+** button
3. Verify the meal appears in the correct section
4. Check that daily totals update correctly
5. Test edit functionality
6. Test delete with confirmation
7. Verify empty state when all meals are deleted

---

**Implementation Date**: March 11, 2026  
**Status**: ✅ Complete and tested  
**No Compilation Errors**: ✅ Verified
