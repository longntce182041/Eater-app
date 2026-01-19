/**
 * Nutritionist management types
 */

export type VerificationStatus = 'pending' | 'approved' | 'rejected' | 'requires_info';

export interface Nutritionist {
  id: string;
  userId: string;
  email: string;
  firstName: string;
  lastName: string;
  avatar?: string;
  specializations: string[];
  qualifications: Qualification[];
  verificationStatus: VerificationStatus;
  verificationNotes?: string;
  verifiedAt?: string;
  verifiedBy?: string;
  licenseNumber?: string;
  yearsOfExperience?: number;
  bio?: string;
  consultationRate?: number;
  availability?: string[];
  rating?: number;
  reviewCount?: number;
  createdAt: string;
  updatedAt: string;
}

export interface Qualification {
  id: string;
  title: string;
  institution: string;
  year: number;
  documentUrl?: string;
  verified: boolean;
}

export interface NutritionistsResponse {
  nutritionists: Nutritionist[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface NutritionistsState {
  nutritionists: Nutritionist[];
  pendingVerifications: Nutritionist[];
  selectedNutritionist: Nutritionist | null;
  totalCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
}
