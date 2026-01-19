/**
 * Recipes list page
 */
export function RecipesListPage() {
  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Recipes</h1>
        <button className="bg-primary text-white px-4 py-2 rounded-lg">
          Add Recipe
        </button>
      </div>
      {/* TODO: Implement recipes table */}
      <div className="bg-white rounded-lg shadow">
        {/* Table component */}
      </div>
    </div>
  );
}
