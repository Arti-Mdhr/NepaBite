import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import '../model/recipe_api_model.dart';

final recipeRemoteDatasourceProvider =
    Provider<RecipeRemoteDatasource>((ref) {
  return RecipeRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class RecipeRemoteDatasource {
  final ApiClient _apiClient;

  RecipeRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<RecipeApiModel>> getRecipes() async {
    final response = await _apiClient.get(ApiEndpoints.recipes);

    final List recipes = response.data['recipes'];

    return recipes
        .map((e) => RecipeApiModel.fromJson(e))
        .toList();
  }
}