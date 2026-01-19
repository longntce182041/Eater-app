/**
 * Ingredients list page
 */
export function IngredientsListPage() {
  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Ingredients</h1>
        <button className="bg-primary text-white px-4 py-2 rounded-lg">
          Add Ingredient
        </button>
      </div>
      {/* TODO: Implement ingredients table */}
      <div className="bg-white rounded-lg shadow">
        {/* Table component */}
      </div>
    </div>
  );
}
