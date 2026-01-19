interface CardProps {
  title?: string;
  subtitle?: string;
  actions?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}

/**
 * Reusable card component
 */
export function Card({
  title,
  subtitle,
  actions,
  children,
  className = '',
}: CardProps) {
  return (
    <div className={`bg-white rounded-lg shadow ${className}`}>
      {(title || actions) && (
        <div className="flex items-center justify-between px-6 py-4 border-b">
          <div>
            {title && <h3 className="text-lg font-semibold">{title}</h3>}
            {subtitle && (
              <p className="text-sm text-gray-500">{subtitle}</p>
            )}
          </div>
          {actions && <div>{actions}</div>}
        </div>
      )}
      <div className="p-6">{children}</div>
    </div>
  );
}
