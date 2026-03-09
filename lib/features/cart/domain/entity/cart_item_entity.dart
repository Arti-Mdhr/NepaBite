class CartItemEntity {
  final String name;
  final String quantity;
  bool isBought;

  CartItemEntity({
    required this.name,
    required this.quantity,
    this.isBought = false,
  });
}