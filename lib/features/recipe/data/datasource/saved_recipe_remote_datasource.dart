import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';

class SavedRecipeRemoteDatasource {
  final ApiClient api;

  SavedRecipeRemoteDatasource(this.api);

  Future<void> saveRecipe(String recipeId) async {
    await api.post(
      ApiEndpoints.saveRecipe,
      data: {
        "recipeId": recipeId,
      },
    );
  }

  Future<List> getSavedRecipes() async {
    final response = await api.get(ApiEndpoints.savedRecipes);
    return response.data["savedRecipes"];
  }

  Future<void> removeRecipe(String recipeId) async {
    await api.delete(ApiEndpoints.removeSavedRecipe(recipeId));
  }
}