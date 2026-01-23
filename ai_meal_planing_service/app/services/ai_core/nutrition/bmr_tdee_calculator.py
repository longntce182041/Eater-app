from app.domain.models.user_profile import UserProfile
from app.domain.models.health_metrics import HealthMetrics


def calculate_bmr(user: UserProfile) -> float:
    """Calculate BMR (e.g., Mifflin-St Jeor)."""
    raise NotImplementedError


def calculate_tdee(user: UserProfile, bmr: float) -> float:
    """Calculate TDEE from BMR & activity level."""
    raise NotImplementedError


def build_health_metrics(user: UserProfile) -> HealthMetrics:
    """Aggregate BMR, TDEE, and target calories."""
    raise NotImplementedError