class SavedRecipeEntity {
  final String id;
  final String title;
  final String image;
  final String? category;
  final String? description;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;

  SavedRecipeEntity({
    required this.id,
    required this.title,
    required this.image,
    this.category,
    this.description,
    List<Map<String, dynamic>>? ingredients,
    List<String>? instructions,
  })  : ingredients = ingredients ?? const [],
        instructions = instructions ?? const [];
}