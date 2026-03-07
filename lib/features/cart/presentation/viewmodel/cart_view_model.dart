import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/cart_item_entity.dart';

final cartProvider =
    NotifierProvider<CartViewModel, List<CartItemEntity>>(CartViewModel.new);

class CartViewModel extends Notifier<List<CartItemEntity>> {

  @override
  List<CartItemEntity> build() {
    return [];
  }

  void addIngredients(List ingredients) {
    final items = ingredients.map<CartItemEntity>((item) {

      // Safely extract name and quantity
      final name = item is Map
          ? (item['name'] ?? 'Unknown').toString()
          : item.name?.toString() ?? 'Unknown';

      final quantity = item is Map
          ? (item['quantity'] ?? '').toString()
          : item.quantity?.toString() ?? '';

      return CartItemEntity(
        name: name,
        quantity: quantity,
        isBought: false,
      );
    }).toList();

    state = [...state, ...items];
  }

  void toggleBought(int index) {
    final updated = state.map((item) => CartItemEntity(
      name: item.name,
      quantity: item.quantity,
      isBought: item.isBought,
    )).toList();

    updated[index].isBought = !updated[index].isBought;
    state = updated;
  }

  void removeItem(int index) {
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
  }

  void clearCart() {
    state = [];
  }
}