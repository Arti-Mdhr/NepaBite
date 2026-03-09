import '../../domain/entity/recipe_entity.dart';

class RecipeApiModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final String category;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;

  RecipeApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    List<Map<String, dynamic>>? ingredients,  // nullable in constructor
    List<String>? instructions,               // nullable in constructor
  })  : ingredients = ingredients ?? [],      // default to empty list
        instructions = instructions ?? [];    // default to empty list

  factory RecipeApiModel.fromJson(Map<String, dynamic> json) {
  return RecipeApiModel(
    id: json['_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    category: json['category']?.toString() ?? '',

    ingredients: (json['ingredients'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],

    instructions: (json['instructions'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
  );
}

  RecipeEntity toEntity() {
    return RecipeEntity(
      id: id,
      title: title,
      description: description,
      image: image,
      category: category,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}