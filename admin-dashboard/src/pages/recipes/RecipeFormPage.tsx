import { useParams } from 'react-router-dom';

/**
 * Recipe form page - Create or edit recipe
 */
export function RecipeFormPage() {
  const { id } = useParams<{ id: string }>();
  const isEditing = Boolean(id);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">
        {isEditing ? 'Edit Recipe' : 'Create Recipe'}
      </h1>
      {/* TODO: Implement recipe form */}
      <div className="bg-white rounded-lg shadow p-6">
        {/* Form component */}
      </div>
    </div>
  );
}
