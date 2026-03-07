import 'package:flutter/material.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/features/review/data/datasource/review_remote_datasource.dart';
import 'package:nepabite/features/review/data/model/review_api_model.dart';
import 'package:nepabite/features/review/domain/entity/review_entity.dart';
import 'recipe_ingredients_screen.dart';
import 'recipe_procedure_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int rating = 5;
  Future<List<ReviewEntity>>? _reviewsFuture;

  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  final ReviewRemoteDatasource _reviewDatasource =
      ReviewRemoteDatasource(ApiClient());
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews(widget.recipe.id);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<List<ReviewEntity>> fetchReviews(String recipeId) async {
    try {
      final rawList = await _reviewDatasource.getReviews(recipeId);
      final parsed = rawList
          .map((e) => ReviewApiModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return parsed;
    } catch (e) {
      debugPrint("Review fetch error: $e");
      return [];
    }
  }

  Future<void> addReview() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _reviewDatasource.addReview(widget.recipe.id, text, rating);
      commentController.clear();
      setState(() => _reviewsFuture = fetchReviews(widget.recipe.id));
      if (mounted) _showSnackBar("Review posted!", isError: false);
    } catch (e) {
      debugPrint("Add review error: $e");
      if (mounted) _showSnackBar("Failed to post review", isError: true);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewDatasource.deleteReview(widget.recipe.id, reviewId);
      setState(() => _reviewsFuture = fetchReviews(widget.recipe.id));
    } catch (e) {
      debugPrint("Delete review error: $e");
      if (mounted) _showSnackBar("Failed to delete review", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  double calculateAverage(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) return 0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                widget.recipe.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            /// CATEGORY PILL
            if (widget.recipe.category != null &&
                (widget.recipe.category as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.recipe.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 14),

            /// IMAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  ApiEndpoints.fileUrl(widget.recipe.image),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.list_alt_rounded, size: 16),
                      label: const Text("Ingredients"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: const BorderSide(color: _green),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeIngredientsScreen(recipe: widget.recipe),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: const Text("Procedure"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: const BorderSide(color: _green),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeProcedureScreen(recipe: widget.recipe),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// DESCRIPTION
            _sectionLabel("Description"),
            const SizedBox(height: 10),
            _card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.recipe.description ?? "",
                  style: const TextStyle(
                    height: 1.6,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// REVIEWS
            _sectionLabel("Reviews"),
            const SizedBox(height: 10),

            FutureBuilder<List<ReviewEntity>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: _green),
                  ));
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                final reviews = snapshot.data ?? [];
                final avg = calculateAverage(reviews);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    _card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  avg == 0 ? "—" : avg.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                buildStarDisplay(avg, size: 20),
                                const SizedBox(height: 2),
                                Text(
                                  "${reviews.length} review${reviews.length == 1 ? '' : 's'}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text(
                          "No reviews yet. Be the first to review!",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),

                    ...reviews.map((r) => reviewCard(r)),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            /// WRITE REVIEW
            _sectionLabel("Write a Review"),
            const SizedBox(height: 10),

            _card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Share your experience...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFF7FAF8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          "Your rating:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () => setState(() => rating = i + 1),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: _green,
                                size: 28,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Post Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildStarDisplay(double value, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (value >= i + 1) {
          return Icon(Icons.star_rounded, color: _green, size: size);
        } else if (value >= i + 0.5) {
          return Icon(Icons.star_half_rounded, color: _green, size: size);
        } else {
          return Icon(Icons.star_border_rounded,
              color: Colors.grey.shade300, size: size);
        }
      }),
    );
  }

  Widget reviewCard(ReviewEntity review) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar initial
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: _greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        color: _green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      buildStarDisplay(review.rating.toDouble(), size: 13),
                    ],
                  ),
                ),
                if (review.isOwner)
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text("Delete Review",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text(
                              "Are you sure you want to delete this review?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text("Cancel",
                                  style: TextStyle(
                                      color: Colors.grey.shade600)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) deleteReview(review.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade400, size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}