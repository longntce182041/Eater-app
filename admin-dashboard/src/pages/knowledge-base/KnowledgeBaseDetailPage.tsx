import { useParams } from 'react-router-dom';

/**
 * Knowledge base article detail page
 */
export function KnowledgeBaseDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Article Details</h1>
      {/* TODO: Implement article detail view */}
      <div className="bg-white rounded-lg shadow p-6">
        <p>Article ID: {id}</p>
      </div>
    </div>
  );
}
