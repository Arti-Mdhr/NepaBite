import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/features/review/data/datasource/review_remote_datasource.dart';

final reviewProvider =
    NotifierProvider<ReviewViewModel, List<dynamic>>(
        ReviewViewModel.new);

class ReviewViewModel extends Notifier<List<dynamic>> {

  late ReviewRemoteDatasource api;

  @override
  List<dynamic> build() {
    api = ReviewRemoteDatasource(ref.read(apiClientProvider));
    return [];
  }

  Future<void> fetchReviews(String recipeId) async {
    final reviews = await api.getReviews(recipeId);
    state = reviews;
  }

  Future<void> addReview(
      String recipeId, String comment, int rating) async {

    await api.addReview(recipeId, comment, rating);

    await fetchReviews(recipeId);
  }

  Future<void> deleteReview(
      String recipeId, String reviewId) async {

    await api.deleteReview(recipeId, reviewId);

    state = state.where((r) => r["_id"] != reviewId).toList();
  }
}