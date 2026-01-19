/**
 * User management types
 */

export interface User {
  id: string;
  email: string;
  username: string;
  firstName?: string;
  lastName?: string;
  avatar?: string;
  role: 'user' | 'premium' | 'nutritionist';
  status: 'active' | 'inactive' | 'banned' | 'pending';
  emailVerified: boolean;
  phoneNumber?: string;
  dateOfBirth?: string;
  gender?: 'male' | 'female' | 'other';
  createdAt: string;
  updatedAt: string;
  lastLogin?: string;
  banReason?: string;
  bannedAt?: string;
  healthProfile?: HealthProfile;
}

export interface HealthProfile {
  height?: number;
  weight?: number;
  activityLevel?: string;
  dietaryRestrictions?: string[];
  allergies?: string[];
  healthGoals?: string[];
}

export interface UserFilters {
  status?: string;
  role?: string;
  search?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface UsersResponse {
  users: User[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface UsersState {
  users: User[];
  selectedUser: User | null;
  totalCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
  filters: UserFilters;
}
