// import 'package:flutter/material.dart';
// import 'package:nepabite/features/cart/domain/entity/grocery_list_entity.dart';

// class GroceryListDetailScreen extends StatelessWidget {
//   final int listNumber;
//   final GroceryListEntity groceryList;

//   const GroceryListDetailScreen({
//     super.key,
//     required this.listNumber,
//     required this.groceryList,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Grocery List $listNumber"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),

//       body: groceryList.items.isEmpty
//           ? const Center(
//               child: Text(
//                 "No ingredients in this list",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: groceryList.items.length,
//               itemBuilder: (context, index) {
//                 final item = groceryList.items[index];

//                 final name = item['name']?.toString() ?? 'Unknown';
//                 final quantity = item['quantity']?.toString() ?? '';

//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     leading: const Icon(
//                       Icons.circle,
//                       size: 10,
//                       color: Color(0xFF1EB980),
//                     ),
//                     title: Text(
//                       name,
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     trailing: Text(
//                       quantity,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }