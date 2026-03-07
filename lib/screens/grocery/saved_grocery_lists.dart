import 'package:flutter/material.dart';
import 'package:nepabite/features/cart/data/grocery_storage_service.dart';
import 'package:nepabite/features/cart/domain/entity/grocery_list_entity.dart';

class SavedGroceryListsScreen extends StatefulWidget {
  const SavedGroceryListsScreen({super.key});

  @override
  State<SavedGroceryListsScreen> createState() =>
      _SavedGroceryListsScreenState();
}

class _SavedGroceryListsScreenState extends State<SavedGroceryListsScreen> {
  final storage = GroceryStorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Grocery Lists")),

      body: FutureBuilder(
        future: storage.getLists(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data!;

          if (lists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No saved lists yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1EB980),
                    child: Icon(Icons.list, color: Colors.white),
                  ),
                  title: Text(
                    "Grocery List ${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("${list.items.length} ingredients"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroceryListDetailScreen(
                          listNumber: index + 1,
                          groceryList: list,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── DETAIL SCREEN ───────────────────────────────────────────────────────────

class GroceryListDetailScreen extends StatelessWidget {
  final int listNumber;
  final GroceryListEntity groceryList;

  const GroceryListDetailScreen({
    super.key,
    required this.listNumber,
    required this.groceryList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grocery List $listNumber"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: groceryList.items.isEmpty
          ? const Center(
              child: Text(
                "No ingredients in this list",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groceryList.items.length,
              itemBuilder: (context, index) {
                final item = groceryList.items[index];

                final name = item['name']?.toString() ?? 'Unknown';
                final quantity = item['quantity']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.circle,
                      size: 10,
                      color: Color(0xFF1EB980),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      quantity,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}