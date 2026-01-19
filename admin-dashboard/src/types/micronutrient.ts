/**
 * Micronutrient management types
 */

export interface Micronutrient {
  id: string;
  name: string;
  category: 'vitamin' | 'mineral' | 'other';
  unit: string;
  dailyRecommendedValue: number;
  description?: string;
  benefits?: string[];
  sources?: string[];
  deficiencySymptoms?: string[];
  excessSymptoms?: string[];
  interactions?: string[];
  createdAt: string;
  updatedAt: string;
}

export interface MicronutrientsState {
  micronutrients: Micronutrient[];
  selectedMicronutrient: Micronutrient | null;
  totalCount: number;
  isLoading: boolean;
  error: string | null;
}
