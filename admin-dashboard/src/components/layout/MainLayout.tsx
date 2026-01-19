import { Outlet, Navigate } from 'react-router-dom';
import { useAppSelector } from '@store/hooks';

import { Sidebar } from './Sidebar';
import { Header } from './Header';

/**
 * Main layout for authenticated admin pages.
 * Includes sidebar navigation and header.
 */
export function MainLayout() {
  const { isAuthenticated, isLoading } = useAppSelector((state) => state.auth);

  // Show loading state while checking auth
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  // Redirect to login if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <Sidebar />

      {/* Main content area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <Header />

        {/* Page content */}
        <main className="flex-1 overflow-y-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
