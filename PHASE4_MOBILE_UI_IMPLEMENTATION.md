# Phase 4: Mobile UI Updates - Implementation Complete

## Overview
Phase 4 has been successfully implemented to enable meal plan optimization features on the mobile app. Users can now rate meals, replace meals, and auto-optimize their entire meal plan with a single click.

## Files Modified

### 1. **Meal Plan Models** 
📄 `mobile/lib/src/features/meal_plan/domain/meal_plan_models.dart`

**Changes:**
- Added three new fields to `MealPlanItemModel`:
  - `userRating` (int?, 1-5 stars)
  - `userAction` (String, default: 'none')
  - `isLocked` (bool, default: false)

**Purpose:** Track user feedback and optimization state for each meal item.

```dart
class MealPlanItemModel {
  // ... existing fields ...
  final int? userRating;        // NEW
  final String userAction;      // NEW
  final bool isLocked;          // NEW
}
```

---

### 2. **API Client**
📄 `mobile/lib/src/features/meal_plan/data/meal_plan_api_client.dart`

**New Methods Added:**

#### `getReplacementSuggestions(planId, itemId)`
- **Endpoint:** `GET /api/meal-plans/{planId}/items/{itemId}/suggestions`
- **Returns:** List of recipe suggestions with similar calories
- **Usage:** Get alternative recipes for a meal within ±100 calories

#### `replaceMeal(planId, itemId, newRecipeId, reason)`
- **Endpoint:** `PATCH /api/meal-plans/{planId}/items/{itemId}/replace`
- **Parameters:**
  - `newRecipeId`: Recipe to replace with
  - `reason`: Why user is replacing (optional)
- **Returns:** Updated `MealPlanItemModel`
- **Recalculates:** Nutrition metrics automatically

#### `rateMeal(planId, itemId, rating)`
- **Endpoint:** `POST /api/meal-plans/{planId}/items/{itemId}/rate`
- **Parameters:** `rating` (1-5)
- **Returns:** Updated `MealPlanItemModel` with userRating set

#### `getOptimizationSuggestions(planId)`
- **Endpoint:** `GET /api/meal-plans/{planId}/optimization-suggestions`
- **Returns:** Map with:
  - Low-rated meals identified
  - Variety score (0-1)
  - Suggested replacements

#### `optimizeMealPlan(planId)`
- **Endpoint:** `POST /api/meal-plans/{planId}/optimize`
- **Performs:** Auto-replaces meals <3 stars and improves variety
- **Returns:** Optimization result with change log

---

### 3. **State Management (Provider)**
📄 `mobile/lib/src/features/meal_plan/presentation/providers/meal_plan_provider.dart`

**New Methods in `MealPlanNotifier`:**

#### `rateMeal(mealPlanId, itemId, rating)`
- Updates meal item with rating
- Reflects changes in current state
- No server reload needed (instant UI update)

#### `replaceMeal(mealPlanId, itemId, newRecipeId, reason)`
- Calls API to replace meal
- Updates local state with new item
- Maintains nutrition recalculation

#### `optimizeMealPlan(mealPlanId)`
- Auto-optimizes entire plan
- Reloads updated meal plan from server
- Updates UI with improvements

---

### 4. **User Interface (Meal Plan Page)**
📄 `mobile/lib/src/features/meal_plan/presentation/pages/meal_plan_page.dart`

**UI Components Added:**

#### A. Meal Item Optimization Controls
New action buttons appear on every meal item card:

1. **Rate Button** (5-star rating)
   - PopupMenu with star ratings
   - Shows current rating or "Rate" label
   - Orange theme (FF9800)
   - Immediate feedback

2. **Replace Button** (for non-locked meals)
   - Opens replacement dialog
   - Asks for replacement reason
   - Suggests similar recipes
   - Only available if `isLocked = false`

#### B. Optimize All Button
- Appears in bottom navigation when meal plan exists
- Green color (4CAF50) to distinguish from regenerate
- Shows confirmation dialog before optimizing
- Displays success/error message

#### C. Bottom Navigation Bar Updates
```
Before: [Create/Regenerate Meal Plan Button]
After:  [Optimize Button] [Regenerate Button]
```
Both buttons available when meal plan exists.

---

## UI Components Details

### Rating System
```dart
// 5-star popup menu
Rate: ⭐ (1 star - Poor)
      ⭐⭐ (2 stars - Fair)
      ⭐⭐⭐ (3 stars - Good)
      ⭐⭐⭐⭐ (4 stars - Very Good)
      ⭐⭐⭐⭐⭐ (5 stars - Excellent)
```

### Replacement Dialog
- Current meal name displayed
- Dropdown to select replacement reason:
  - "Don't like the taste"
  - "Have allergies"
  - "Too difficult to prepare"
  - "Ingredients not available"
- Gets suggestions or manual selection

### Meal Item Card Layout
```
┌─────────────────────────────────────┐
│ [Meal Type] [Image] [Meal Info]     │
│                                       │
│ P: 25g | C: 45g | F: 12g             │
│                                       │
│ [Rate⭐] [Replace↔️]                 │
└─────────────────────────────────────┘
```

---

## User Workflows

### Workflow 1: Rate a Meal
1. User sees meal item card
2. Clicks "Rate" button
3. Selects rating from 1-5 stars
4. Rating updates immediately
5. Low-rated meals eligible for auto-optimization

### Workflow 2: Replace a Meal
1. User clicks "Replace" on meal card
2. Selects reason for replacement
3. System fetches similar recipes
4. User selects new recipe
5. Meal nutrients recalculated
6. Meal plan totals updated

### Workflow 3: Auto-Optimize Plan
1. User clicks "Optimize" button
2. Confirmation dialog appears
3. User confirms optimization
4. System:
   - Replaces <3 star meals
   - Removes duplicate recipes
   - Maintains calorie targets
   - Improves variety score
5. Returns to updated meal plan view

---

## Data Validation & Error Handling

### Input Validation
- ✓ Rating: 1-5 only
- ✓ Recipe ID: Required for replacement
- ✓ Plan ID: Must exist
- ✓ Item ID: Must exist in plan

### Error Messages
- Clear, user-friendly messages
- SnackBar notifications for actions
- Dialog confirmations for destructive actions
- Loading states during API calls

### Edge Cases Handled
- Locked meals (no replace button)
- Empty rating display ("Rate" vs "4/5")
- Missing recipe images (placeholder icon)
- Network errors (retry prompts)

---

## Integration with Backend

### API Routes Connected
All routes protected with authentication middleware:

| Method | Route | Controller |
|--------|-------|-----------|
| GET | `/api/meal-plans/{planId}/items/{itemId}/suggestions` | `getReplacementSuggestions` |
| PATCH | `/api/meal-plans/{planId}/items/{itemId}/replace` | `replaceMealInPlan` |
| POST | `/api/meal-plans/{planId}/items/{itemId}/rate` | `rateMealItem` |
| GET | `/api/meal-plans/{planId}/optimization-suggestions` | `getOptimizationSuggestions` |
| POST | `/api/meal-plans/{planId}/optimize` | `optimizeEntirePlan` |

### Data Flow
```
Mobile UI → API Client → Riverpod Provider → Backend
                  ↓
Mobile UI Updated ← Provider State ← API Response
```

---

## Testing Recommendations

### Unit Tests
- [ ] MealPlanItemModel serialization with new fields
- [ ] Rating validation (1-5 range)
- [ ] Meal locks prevent replacement

### Widget Tests
- [ ] Star rating popup displays correctly
- [ ] Replace button hidden for locked meals
- [ ] Optimize button only shows with meal plan
- [ ] Action buttons layout responsive

### Integration Tests
- [ ] Rate meal updates UI immediately
- [ ] Replace meal recomputes nutrition
- [ ] Optimize plan shows success/error
- [ ] Network errors handled gracefully

### Manual Testing Checklist
- [ ] Create meal plan → See optimization buttons
- [ ] Rate meal 1-5 stars → See updated rating
- [ ] Replace meal → Get suggestions
- [ ] Click Optimize All → Confirm dialog → See changes
- [ ] Delete all plans → Buttons disappear
- [ ] Network error → Error message appears
- [ ] Test on various screen sizes

---

## Performance Considerations

### Optimization
- API calls debounced for ratings
- Local state updates before server confirmation
- Pagination for large replacement lists
- Image caching for recipe thumbnails

### Future Enhancements
1. **Batch Operations**
   - Rate multiple meals at once
   - Replace multiple meals in dialog

2. **Advanced Filters**
   - Filter replacements by cuisine/diet
   - Show nutritional differences

3. **History Tracking**
   - Undo/redo meal replacements
   - See optimization history

4. **Smart Recommendations**
   - ML-based meal suggestions
   - Learn from user ratings
   - Personalized replacements

---

## Summary of Changes

✅ **Models:** Added `userRating`, `userAction`, `isLocked` to MealPlanItemModel  
✅ **API Client:** 5 new methods for optimization endpoints  
✅ **Provider:** 3 new state mutations for meal operations  
✅ **UI:** Rating popup, Replace dialog, Optimize button, action buttons  
✅ **Error Handling:** Comprehensive validation and user feedback  
✅ **Code Quality:** Dart formatting, null safety, proper typing  

---

## Files Summary

| File | Type | Status |
|------|------|--------|
| meal_plan_models.dart | Domain | ✓ Updated |
| meal_plan_api_client.dart | Data | ✓ Updated (5 methods added) |
| meal_plan_provider.dart | State | ✓ Updated (3 methods added) |
| meal_plan_page.dart | Presentation | ✓ Updated (3 widgets + logic) |

---

## Next Steps

1. **Testing:** Run widget and integration tests
2. **Deployment:** Deploy mobile app to TestFlight/Google Play
3. **User Feedback:** Gather ratings and replacement suggestions
4. **Analytics:** Track optimization metrics
5. **Iteration:** Refine based on user behavior

---

**Implementation Date:** February 25, 2026  
**Status:** Complete and Ready for Testing
