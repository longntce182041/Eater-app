import { useParams } from 'react-router-dom';

/**
 * Nutritionist detail page
 */
export function NutritionistDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Nutritionist Details</h1>
      {/* TODO: Implement nutritionist detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>Nutritionist ID: {id}</p>
      </div>
    </div>
  );
}
