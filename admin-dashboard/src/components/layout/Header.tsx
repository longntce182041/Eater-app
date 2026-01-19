import { useAppSelector, useAppDispatch } from '@store/hooks';
import { logout } from '@features/auth/authSlice';

/**
 * Header component with user info and actions
 */
export function Header() {
  const dispatch = useAppDispatch();
  const { user } = useAppSelector((state) => state.auth);

  const handleLogout = () => {
    dispatch(logout());
  };

  return (
    <header className="h-16 bg-white shadow-sm flex items-center justify-between px-6">
      {/* Search */}
      <div className="flex-1 max-w-lg">
        <div className="relative">
          <input
            type="search"
            placeholder="Search..."
            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/50"
          />
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
            🔍
          </span>
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center space-x-4">
        {/* Notifications */}
        <button className="relative p-2 text-gray-600 hover:bg-gray-100 rounded-lg">
          <span>🔔</span>
          <span className="absolute top-0 right-0 h-4 w-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
            3
          </span>
        </button>

        {/* User menu */}
        <div className="flex items-center space-x-3">
          <div className="text-right">
            <p className="text-sm font-medium text-gray-900">
              {user?.firstName || user?.username || 'Admin'}
            </p>
            <p className="text-xs text-gray-500">{user?.role}</p>
          </div>
          <div className="h-10 w-10 bg-primary/10 rounded-full flex items-center justify-center">
            {user?.avatar ? (
              <img
                src={user.avatar}
                alt={user.username}
                className="h-10 w-10 rounded-full object-cover"
              />
            ) : (
              <span className="text-primary font-medium">
                {user?.firstName?.[0] || user?.username?.[0] || 'A'}
              </span>
            )}
          </div>
          <button
            onClick={handleLogout}
            className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg"
            title="Logout"
          >
            🚪
          </button>
        </div>
      </div>
    </header>
  );
}
