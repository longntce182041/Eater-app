# Dietary References - Multi-Page Implementation

## Overview
The dietary references flow has been split into 6 separate pages with validation for each step.

## Navigation Flow
```
/set-gender 
  → /select-diet-type (required)
    → /select-allergies (optional - can skip)
      → /select-dislikes (optional - can skip)
        → /select-activity-level (required)
          → /select-cooking (required - skill + time)
            → /select-calories (required)
              → /profile-summary
```

## Created Files

### 1. Provider (Shared State)
**File**: `lib/src/features/userHeath/presentation/providers/dietary_ref_provider.dart`
- **DietaryRefData**: Model class with all dietary fields
- **DietaryRefState**: State management with loading/error handling
- **DietaryRefNotifier**: Methods to update each field individually
- **dietTypesProvider**: FutureProvider to fetch diet types from API
- **dietaryRefProvider**: Main StateNotifierProvider

### 2. Page 1: Select Diet Type
**File**: `lib/src/features/userHeath/presentation/screens/select_diet_type_page.dart`
- **Validation**: Must select a diet type
- **UI**: List of diet type cards with name, description, and macro ratios
- **API**: Fetches from `/api/health/diet-types`
- **Navigation**: → `/select-allergies`

### 3. Page 2: Select Allergies
**File**: `lib/src/features/userHeath/presentation/screens/select_allergies_page.dart`
- **Validation**: Optional (can skip)
- **UI**: 
  - Common allergies as FilterChips (Dairy, Eggs, Peanuts, etc.)
  - Custom allergy input field
  - "Skip" button in AppBar
- **Navigation**: → `/select-dislikes`

### 4. Page 3: Select Dislikes
**File**: `lib/src/features/userHeath/presentation/screens/select_dislikes_page.dart`
- **Validation**: Optional (can skip)
- **UI**: 
  - Common ingredients as FilterChips (Mushrooms, Onions, etc.)
  - Custom ingredient input field
  - "Skip" button in AppBar
- **Navigation**: → `/select-activity-level`

### 5. Page 4: Select Activity Level
**File**: `lib/src/features/userHeath/presentation/screens/select_activity_level_page.dart`
- **Validation**: Must select an activity level
- **UI**: 5 activity levels (Sedentary, Lightly Active, Moderately Active, Very Active, Extra Active)
- **Options**: Each with description of exercise frequency
- **Navigation**: → `/select-cooking`

### 6. Page 5: Select Cooking Preferences
**File**: `lib/src/features/userHeath/presentation/screens/select_cooking_page.dart`
- **Validation**: Must select skill level AND enter cooking time
- **UI**:
  - Cooking skill level cards (Beginner, Intermediate, Advanced, Expert)
  - Available cooking time input (minutes per day)
- **Navigation**: → `/select-calories`

### 7. Page 6: Select Daily Calories
**File**: `lib/src/features/userHeath/presentation/screens/select_calories_page.dart`
- **Validation**: 
  - Must enter a value
  - Minimum 1000 calories
  - Maximum 5000 calories
- **UI**:
  - Large input field for calorie target
  - Recommended ranges card (Weight Loss, Maintenance, Muscle Gain, Athletic)
- **Action**: Submits all dietary data to `/api/health/dietary-references`
- **Navigation**: → `/profile-summary` (on success)

## Router Configuration
**File**: `lib/src/config/router/app_router.dart`

Added 6 new routes:
- `/select-diet-type` → SelectDietTypePage
- `/select-allergies` → SelectAllergiesPage
- `/select-dislikes` → SelectDislikesPage
- `/select-activity-level` → SelectActivityLevelPage
- `/select-cooking` → SelectCookingPage
- `/select-calories` → SelectCaloriesPage

All routes are marked as `isAuthRoute` to allow authenticated users during setup.

## Backend Endpoints

### Already Implemented:
✅ `GET /api/health/diet-types` - Fetches all diet types
✅ `POST /api/health/dietary-references` - Saves all dietary preferences

**Request Body for dietary-references**:
```json
{
  "diet_typeId": "string (ObjectId)",
  "allergies": ["string"],
  "dislikesIngredients": ["string"],
  "activityLevel": "string",
  "cookingSkillLevel": "string",
  "available_cooking_time": number,
  "daily_calorie_target": number
}
```

## Validation Rules

### Required Fields:
1. **Diet Type ID** - Must be selected
2. **Activity Level** - Must be selected
3. **Cooking Skill Level** - Must be selected
4. **Available Cooking Time** - Must be a positive number
5. **Daily Calorie Target** - Must be between 1000-5000

### Optional Fields:
- **Allergies** - Can be empty array
- **Dislikes Ingredients** - Can be empty array

## Design System
All pages follow the existing design pattern:
- Background: `Color(0xFFF5F1E8)` (beige)
- Primary Button: `Color(0xFFFF9800)` (orange)
- Cards: White with shadow, 12px border radius
- Selected State: Orange border (2px)
- Typography: 32px bold titles, 16px subtitles

## User Flow States

### Success Path:
1. User completes gender/activity on setGenderActivity page
2. Navigates through all 6 dietary pages
3. Submits on calories page
4. Data saved to backend
5. Redirected to profile-summary

### Partial Completion:
- User can skip allergies and dislikes
- Navigation preserves data in dietaryRefProvider
- Can go back and forth between pages

### Error Handling:
- Validation errors shown in red below forms
- API errors shown via SnackBar
- Loading state prevents double-submission

## Next Steps
**Waiting for user to provide design requirements for each page**

The user mentioned: "when you finish i will give you each page design required"

All 6 pages are now functional with basic validation. Ready for design customization.
