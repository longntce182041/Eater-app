import { useParams } from 'react-router-dom';

/**
 * User detail page - View and edit individual user
 */
export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">User Details</h1>
      {/* TODO: Implement user detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>User ID: {id}</p>
      </div>
    </div>
  );
}
