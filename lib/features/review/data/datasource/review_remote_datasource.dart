import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';

class ReviewRemoteDatasource {
  final ApiClient api;

  ReviewRemoteDatasource(this.api);

  Future<List> getReviews(String recipeId) async {
    final res = await api.get(ApiEndpoints.recipeById(recipeId));
    return res.data["recipe"]["reviews"];
  }

  Future<void> addReview(
      String recipeId, String comment, int rating) async {
    await api.post(
      "/recipes/review",
      data: {
        "recipeId": recipeId,
        "comment": comment,
        "rating": rating,
      },
    );
  }

  Future<void> deleteReview(
      String recipeId, String reviewId) async {
    await api.delete(
      "/recipes/review/$recipeId/$reviewId",
    );
  }
}