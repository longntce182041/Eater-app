/**
 * Authentication related types
 */

export interface User {
  id: string;
  email: string;
  username: string;
  role: 'admin' | 'super_admin';
  firstName?: string;
  lastName?: string;
  avatar?: string;
  createdAt: string;
  lastLogin?: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}
