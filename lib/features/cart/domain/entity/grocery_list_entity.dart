class GroceryListEntity {
  final String id;
  final List<Map<String, dynamic>> items;

  GroceryListEntity({
    required this.id,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "items": items,
    };
  }

  factory GroceryListEntity.fromJson(Map<String, dynamic> json) {
    return GroceryListEntity(
      id: json["id"],
      items: List<Map<String, dynamic>>.from(json["items"]),
    );
  }
}