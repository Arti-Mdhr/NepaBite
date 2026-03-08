import 'package:flutter/foundation.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';

class ReviewRemoteDatasource {
  final ApiClient api;

  ReviewRemoteDatasource(this.api);

  Future<List> getReviews(String recipeId) async {
    final res = await api.get(ApiEndpoints.recipeById(recipeId));
    return res.data["recipe"]["reviews"] ?? [];
  }

  Future<void> addReview(
      String recipeId, String comment, int rating) async {
    try {
      final res = await api.post(
        "/recipes/review",
        data: {
          "recipeId": recipeId,
          "comment": comment,
          "rating": rating,
        },
      );
      debugPrint("[ReviewDatasource] addReview response: ${res.statusCode} ${res.data}");

      // treat any non-2xx or success:false as an error
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return; // success
      }
      throw Exception(
          "Unexpected status ${res.statusCode}: ${res.data}");
    } catch (e) {
      debugPrint("[ReviewDatasource] addReview ERROR: $e");
      rethrow; // let the screen's catch block handle it
    }
  }

  Future<void> deleteReview(String recipeId, String reviewId) async {
    try {
      final res = await api.delete(
        "/recipes/review/$recipeId/$reviewId",
      );
      debugPrint("[ReviewDatasource] deleteReview response: ${res.statusCode} ${res.data}");
    } catch (e) {
      debugPrint("[ReviewDatasource] deleteReview ERROR: $e");
      rethrow;
    }
  }
}