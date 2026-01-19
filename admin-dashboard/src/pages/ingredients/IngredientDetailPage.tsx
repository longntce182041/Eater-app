import { useParams } from 'react-router-dom';

/**
 * Ingredient detail page
 */
export function IngredientDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Ingredient Details</h1>
      {/* TODO: Implement ingredient detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>Ingredient ID: {id}</p>
      </div>
    </div>
  );
}
