import { NavLink } from 'react-router-dom';

interface NavItem {
  path: string;
  label: string;
  icon: string;
  badge?: number;
}

interface NavGroup {
  title: string;
  items: NavItem[];
}

const navigationGroups: NavGroup[] = [
  {
    title: 'Overview',
    items: [
      { path: '/dashboard', label: 'Dashboard', icon: '📊' },
      { path: '/analytics', label: 'Analytics', icon: '📈' },
    ],
  },
  {
    title: 'User Management',
    items: [
      { path: '/users', label: 'Users', icon: '👥' },
      { path: '/nutritionists', label: 'Nutritionists', icon: '🩺' },
      { path: '/nutritionists/verification', label: 'Verifications', icon: '✅' },
    ],
  },
  {
    title: 'Content Management',
    items: [
      { path: '/recipes', label: 'Recipes', icon: '🍽️' },
      { path: '/ingredients', label: 'Ingredients', icon: '🥕' },
      { path: '/micronutrients', label: 'Micronutrients', icon: '💊' },
      { path: '/knowledge-base', label: 'Knowledge Base', icon: '📚' },
    ],
  },
  {
    title: 'Moderation',
    items: [
      { path: '/reviews', label: 'Reviews', icon: '⭐' },
      { path: '/reviews/moderation', label: 'Moderation Queue', icon: '🚨' },
    ],
  },
];

/**
 * Sidebar navigation component
 */
export function Sidebar() {
  return (
    <aside className="w-64 bg-white shadow-md flex flex-col">
      {/* Logo */}
      <div className="h-16 flex items-center justify-center border-b">
        <h1 className="text-xl font-bold text-primary">
          🍽️ Meal Planner Admin
        </h1>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-4">
        {navigationGroups.map((group) => (
          <div key={group.title} className="mb-6">
            <h3 className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
              {group.title}
            </h3>
            <ul>
              {group.items.map((item) => (
                <li key={item.path}>
                  <NavLink
                    to={item.path}
                    className={({ isActive }) =>
                      `flex items-center px-4 py-2 text-sm ${
                        isActive
                          ? 'bg-primary/10 text-primary border-r-2 border-primary'
                          : 'text-gray-700 hover:bg-gray-100'
                      }`
                    }
                  >
                    <span className="mr-3">{item.icon}</span>
                    <span>{item.label}</span>
                    {item.badge && (
                      <span className="ml-auto bg-red-500 text-white text-xs rounded-full px-2 py-0.5">
                        {item.badge}
                      </span>
                    )}
                  </NavLink>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t text-xs text-gray-500 text-center">
        v1.0.0
      </div>
    </aside>
  );
}
