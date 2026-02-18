from app.domain.models.user_profile import UserProfile
from app.domain.models.health_metrics import HealthMetrics


def calculate_bmr(user: UserProfile) -> float:
    """
    Calculate BMR using Mifflin-St Jeor equation.

    For men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
    For women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161

    Args:
        user: UserProfile containing age, gender, height, weight

    Returns:
        float: Basal Metabolic Rate in calories/day
    """
    base_bmr = (10 * user.weight_kg) + (6.25 * user.height_cm) - (5 * user.age)

    if user.gender.lower() == "male":
        return base_bmr + 5
    elif user.gender.lower() == "female":
        return base_bmr - 161
    else:
        # For "other" gender, use average of male and female
        return base_bmr - 78


def calculate_tdee(user: UserProfile, bmr: float) -> float:
    """
    Calculate TDEE from BMR & activity level.

    Activity Level Multipliers:
    - sedentary: 1.2 (little or no exercise)
    - light: 1.375 (light exercise 1-3 days/week)
    - moderate: 1.55 (moderate exercise 3-5 days/week)
    - active: 1.725 (hard exercise 6-7 days/week)
    - very_active: 1.9 (very hard exercise, physical job)

    Args:
        user: UserProfile containing activity level
        bmr: Basal Metabolic Rate

    Returns:
        float: Total Daily Energy Expenditure in calories/day
    """
    activity_multipliers = {
        "sedentary": 1.2,
        "light": 1.375,
        "moderate": 1.55,
        "active": 1.725,
        "very_active": 1.9,
    }

    activity_level = user.activity_level.lower()
    multiplier = activity_multipliers.get(activity_level, 1.55)  # Default to moderate

    return bmr * multiplier


def calculate_target_calories(tdee: float, health_goal: str = "maintenance") -> float:
    """
    Calculate target calories based on health goals.

    Goals:
    - weight_loss: TDEE - 500 (1 lb/week loss)
    - aggressive_weight_loss: TDEE - 750 (1.5 lb/week loss)
    - weight_gain: TDEE + 500 (1 lb/week gain)
    - muscle_gain: TDEE + 300 (lean muscle gain)
    - maintenance: TDEE (maintain current weight)

    Args:
        tdee: Total Daily Energy Expenditure
        health_goal: User's health goal

    Returns:
        float: Target calories per day
    """
    goal_adjustments = {
        "weight_loss": -500,
        "aggressive_weight_loss": -750,
        "weight_gain": 500,
        "muscle_gain": 300,
        "maintenance": 0,
    }

    goal_key = health_goal.lower().replace(" ", "_")
    adjustment = goal_adjustments.get(goal_key, 0)

    target = tdee + adjustment

    # Ensure minimum safe calorie intake
    # Women: minimum 1200, Men: minimum 1500, Other: 1350 average
    min_calories = 1200

    return max(target, min_calories)


def build_health_metrics(user: UserProfile, health_goal: str = "maintenance") -> HealthMetrics:
    """
    Aggregate BMR, TDEE, and target calories into a HealthMetrics object.

    This is the main function for analyzing user profile and determining
    their nutritional requirements.

    Args:
        user: UserProfile with physical characteristics and activity level
        health_goal: User's primary health goal (default: "maintenance")

    Returns:
        HealthMetrics: Complete health metrics including BMR, TDEE, and target calories
    """
    bmr = calculate_bmr(user)
    tdee = calculate_tdee(user, bmr)
    target_calories = calculate_target_calories(tdee, health_goal)

    return HealthMetrics(
        bmr=round(bmr, 2),
        tdee=round(tdee, 2),
        target_calories=round(target_calories, 2),
    )


def analyze_user_profile(user: UserProfile, health_goals: list[str] = None) -> dict:
    """
    Comprehensive user profile analysis function.

    Analyzes user's physical characteristics, activity level, and health goals
    to provide complete nutritional insights.

    Args:
        user: UserProfile with all user data
        health_goals: List of health goals (uses first one for calculations)

    Returns:
        dict: Comprehensive analysis including metrics, recommendations, and insights
    """
    primary_goal = health_goals[0] if health_goals else "maintenance"
    health_metrics = build_health_metrics(user, primary_goal)

    # Calculate BMI for additional insights
    bmi = user.weight_kg / ((user.height_cm / 100) ** 2)

    # Determine BMI category
    if bmi < 18.5:
        bmi_category = "underweight"
    elif 18.5 <= bmi < 25:
        bmi_category = "normal_weight"
    elif 25 <= bmi < 30:
        bmi_category = "overweight"
    else:
        bmi_category = "obese"

    return {
        "user_id": user.user_id,
        "health_metrics": health_metrics,
        "bmi": round(bmi, 2),
        "bmi_category": bmi_category,
        "primary_health_goal": primary_goal,
        "activity_level": user.activity_level,
        "analysis_summary": {
            "bmr_explanation": f"Your body burns {health_metrics.bmr} calories at rest",
            "tdee_explanation": f"With {user.activity_level} activity, you burn {health_metrics.tdee} calories daily",
            "target_explanation": f"To achieve {primary_goal}, target {health_metrics.target_calories} calories/day",
        },
    }