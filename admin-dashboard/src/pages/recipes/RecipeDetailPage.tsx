import { useParams } from 'react-router-dom';

/**
 * Recipe detail page
 */
export function RecipeDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Recipe Details</h1>
      {/* TODO: Implement recipe detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>Recipe ID: {id}</p>
      </div>
    </div>
  );
}
