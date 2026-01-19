import { Outlet, Navigate } from 'react-router-dom';
import { useAppSelector } from '@store/hooks';

/**
 * Auth layout for login and authentication pages.
 * Minimal layout without sidebar.
 */
export function AuthLayout() {
  const { isAuthenticated } = useAppSelector((state) => state.auth);

  // Redirect to dashboard if already authenticated
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="max-w-md w-full">
        {/* Logo */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            AI Meal Planner
          </h1>
          <p className="text-gray-600 mt-2">Admin Dashboard</p>
        </div>

        {/* Auth form container */}
        <div className="bg-white rounded-lg shadow-md p-8">
          <Outlet />
        </div>
      </div>
    </div>
  );
}
