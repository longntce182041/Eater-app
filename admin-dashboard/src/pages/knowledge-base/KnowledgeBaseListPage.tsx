/**
 * Knowledge base list page
 */
export function KnowledgeBaseListPage() {
  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Nutrition Knowledge Base</h1>
        <button className="bg-primary text-white px-4 py-2 rounded-lg">
          Add Article
        </button>
      </div>
      {/* TODO: Implement articles table */}
      <div className="bg-white rounded-lg shadow">
        {/* Table component */}
      </div>
    </div>
  );
}
