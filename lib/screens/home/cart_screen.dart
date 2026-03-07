import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/features/cart/data/grocery_storage_service.dart';
import 'package:nepabite/features/cart/domain/entity/grocery_list_entity.dart';
import 'package:nepabite/features/cart/presentation/viewmodel/cart_view_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartProvider.notifier).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final boughtCount = cartItems.where((e) => e.isBought).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Ingredient Grocery List",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),

      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: _greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Your list is empty",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Add ingredients from a recipe",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [

                // Progress indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        "$boughtCount of ${cartItems.length} collected",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${((boughtCount / cartItems.length) * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: cartItems.isEmpty
                          ? 0
                          : boughtCount / cartItems.length,
                      backgroundColor: Colors.grey.shade200,
                      color: _green,
                      minHeight: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _cartItemCard(item, index);
                    },
                  ),
                ),
              ],
            ),

      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [

                  // Clear Cart
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade300),
                        foregroundColor: Colors.red.shade400,
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text("Clear List",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                                "Remove all items from your grocery list?"),
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
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Clear",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(cartProvider.notifier).clearCart();
                        }
                      },
                      child: const Text(
                        "Clear List",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Save List
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (cartItems.isEmpty) return;

                        final items = cartItems
                            .map((e) => {
                                  'name': e.name,
                                  'quantity': e.quantity,
                                })
                            .toList();

                        final groceryList = GroceryListEntity(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          items: items,
                        );

                        await GroceryStorageService().saveList(groceryList);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text("Grocery list saved!"),
                                ],
                              ),
                              backgroundColor: _green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Save List",
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
    );
  }

  Widget _cartItemCard(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [

            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.isBought,
                onChanged: (_) {
                  ref.read(cartProvider.notifier).toggleBought(index);
                },
                activeColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
            ),

            const SizedBox(width: 14),

            // Name + quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: item.isBought
                          ? Colors.grey.shade400
                          : Colors.black87,
                      decoration: item.isBought
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey.shade400,
                    ),
                  ),
                  if (item.quantity.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isBought
                            ? Colors.grey.shade100
                            : _greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.quantity,
                        style: TextStyle(
                          fontSize: 11,
                          color: item.isBought
                              ? Colors.grey.shade400
                              : _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () {
                ref.read(cartProvider.notifier).removeItem(index);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade400,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}