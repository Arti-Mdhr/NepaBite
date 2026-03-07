import 'package:equatable/equatable.dart';

class RecipeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String image;
  final String category;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;
  final double averageRating;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    List<Map<String, dynamic>>? ingredients,
    List<String>? instructions,
    this.averageRating = 0.0,
  })  : ingredients = ingredients ?? const [],
        instructions = instructions ?? const [];

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        image,
        category,
        ingredients,
        instructions,
        averageRating,
      ];
}