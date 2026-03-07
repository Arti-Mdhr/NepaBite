import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
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
  int selectedButton = 0;
  late Future<List<ReviewEntity>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews(widget.recipe.id);
  }

  Future<List<ReviewEntity>> fetchReviews(String recipeId) async {
    try {
      final response = await Dio().get(
        "${ApiEndpoints.baseUrl}/reviews/$recipeId",
      );
      final reviews = response.data["reviews"] as List;
      return reviews
          .map((e) => ReviewApiModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            Padding(
              padding: const EdgeInsets.all(16),
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

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.recipe.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// CATEGORY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.recipe.category ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedButton == 1
                            ? const Color(0xFF1EB980)
                            : Colors.white,
                        foregroundColor: selectedButton == 1
                            ? Colors.white
                            : const Color(0xFF1EB980),
                        side: const BorderSide(color: Color(0xFF1EB980)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() => selectedButton = 1);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeIngredientsScreen(
                                recipe: widget.recipe),
                          ),
                        );
                      },
                      child: const Text("Ingredients"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedButton == 2
                            ? const Color(0xFF1EB980)
                            : Colors.white,
                        foregroundColor: selectedButton == 2
                            ? Colors.white
                            : const Color(0xFF1EB980),
                        side: const BorderSide(color: Color(0xFF1EB980)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() => selectedButton = 2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeProcedureScreen(
                                recipe: widget.recipe),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.recipe.description ?? "",
                style: const TextStyle(
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// REVIEWS SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Reviews",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<ReviewEntity>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {

                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // ERROR or EMPTY
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "No reviews yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final reviews = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildReviewCard(review);
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // USERNAME + STARS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF1EB980),
                      size: 16,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // COMMENT
            Text(
              review.comment,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}