import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/features/cart/data/datasource/cart_remote_datasource.dart';
import 'package:nepabite/features/cart/domain/entity/cart_item_entity.dart';

final cartProvider =
    NotifierProvider<CartViewModel, List<CartItemEntity>>(CartViewModel.new);

class CartViewModel extends Notifier<List<CartItemEntity>> {

  late CartRemoteDatasource cartApi;

  @override
  List<CartItemEntity> build() {
    cartApi = CartRemoteDatasource(ref.read(apiClientProvider));
    return [];
  }

  // Add multiple ingredients from recipe
  void addIngredients(List ingredients) {
    final items = ingredients.map<CartItemEntity>((item) {
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

    // Update local state immediately
    state = [...state, ...items];

    // Sync each item to backend in background
    for (final item in items) {
      final qty = int.tryParse(item.quantity) ?? 1;
      cartApi.addItem(item.name, qty).catchError((e) {
        print("Failed to sync item to backend: $e");
      });
    }
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
    final item = state[index];

    final updated = [...state];
    updated.removeAt(index);
    state = updated;

    // Sync removal to backend in background
    cartApi.removeItem(item.name).catchError((e) {
      print("Failed to remove item from backend: $e");
    });
  }

  void clearCart() {
    // Remove all items from backend
    for (final item in state) {
      cartApi.removeItem(item.name).catchError((e) {
        print("Failed to remove item from backend: $e");
      });
    }
    state = [];
  }

  // Load cart from backend
  Future<void> fetchCart() async {
    try {
      final items = await cartApi.getCart();
      state = items.map<CartItemEntity>((item) {
        return CartItemEntity(
          name: (item['name'] ?? 'Unknown').toString(),
          quantity: (item['quantity'] ?? '').toString(),
          isBought: false,
        );
      }).toList();
    } catch (e) {
      print("Failed to fetch cart: $e");
    }
  }
}