import { useParams } from 'react-router-dom';

/**
 * Micronutrient detail page
 */
export function MicronutrientDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Micronutrient Details</h1>
      {/* TODO: Implement micronutrient detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>Micronutrient ID: {id}</p>
      </div>
    </div>
  );
}
