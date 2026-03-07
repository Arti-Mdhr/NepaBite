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

  // ✅ Initialize at declaration — avoids LateInitializationError entirely
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

  /// FETCH REVIEWS
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

  /// ADD REVIEW
  Future<void> addReview() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await _reviewDatasource.addReview(
        widget.recipe.id,
        text,
        rating,
      );

      commentController.clear();

      setState(() {
        _reviewsFuture = fetchReviews(widget.recipe.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review posted!")),
        );
      }
    } catch (e) {
      debugPrint("Add review error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post review: $e")),
        );
      }
    }
  }

  /// DELETE REVIEW
  Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewDatasource.deleteReview(widget.recipe.id, reviewId);

      setState(() {
        _reviewsFuture = fetchReviews(widget.recipe.id);
      });
    } catch (e) {
      debugPrint("Delete review error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete review: $e")),
        );
      }
    }
  }

  /// CALCULATE AVERAGE
  double calculateAverage(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) return 0;
    double total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE (above image)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                widget.recipe.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            /// CATEGORY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.recipe.category ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),

            /// IMAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ApiEndpoints.fileUrl(widget.recipe.image),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// INGREDIENT / PROCEDURE BUTTONS — outlined, white bg
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1EB980),
                        side: const BorderSide(color: Color(0xFF1EB980)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeIngredientsScreen(recipe: widget.recipe),
                          ),
                        );
                      },
                      child: const Text("Ingredients"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1EB980),
                        side: const BorderSide(color: Color(0xFF1EB980)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeProcedureScreen(recipe: widget.recipe),
                          ),
                        );
                      },
                      child: const Text("Procedure"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// DESCRIPTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.recipe.description ?? ""),
            ),

            const SizedBox(height: 24),

            /// REVIEWS SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Reviews",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<ReviewEntity>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Error loading reviews: ${snapshot.error}"),
                  );
                }

                final reviews = snapshot.data ?? [];
                final avg = calculateAverage(reviews);

                return Column(
                  children: [

                    /// AVERAGE STARS (half-star support)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          buildStarDisplay(avg, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "${avg.toStringAsFixed(1)} (${reviews.length} reviews)",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("No reviews yet. Be the first to review!"),
                      ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return reviewCard(reviews[index]);
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// WRITE REVIEW
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Write a Review",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Share your experience...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// STAR SELECTOR
                  Row(
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFF1EB980),
                        ),
                        onPressed: () {
                          setState(() {
                            rating = i + 1;
                          });
                        },
                      );
                    }),
                  ),

                  ElevatedButton(
                    onPressed: addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1EB980),
                    ),
                    child: const Text(
                      "Post Review",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// HALF-STAR DISPLAY — supports values like 4.5
  Widget buildStarDisplay(double value, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (value >= i + 1) {
          // Full star
          return Icon(Icons.star, color: const Color(0xFF1EB980), size: size);
        } else if (value >= i + 0.5) {
          // Half star
          return Icon(Icons.star_half, color: const Color(0xFF1EB980), size: size);
        } else {
          // Empty star
          return Icon(Icons.star_border, color: const Color(0xFF1EB980), size: size);
        }
      }),
    );
  }

  /// REVIEW CARD
  Widget reviewCard(ReviewEntity review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF1EB980),
                      size: 16,
                    );
                  }),
                ),

                if (review.isOwner)
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Review"),
                          content: const Text("Are you sure you want to delete this review?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) deleteReview(review.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 18),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            Text(review.comment),
          ],
        ),
      ),
    );
  }
}