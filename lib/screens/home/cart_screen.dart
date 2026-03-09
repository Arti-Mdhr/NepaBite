import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nepabite/features/cart/data/grocery_storage_service.dart';
import 'package:nepabite/features/cart/domain/entity/grocery_list_entity.dart';
import 'package:nepabite/features/cart/presentation/viewmodel/cart_view_model.dart';

// ── Mock mart data ──
const _mockMarts = [
  {
    'name': 'Bhatbhateni Superstore',
    'area': 'Naxal, Kathmandu',
    'distance': '0.4 km',
    'open': true,
    'rating': 4.5,
    'tags': ['Vegetables', 'Spices', 'Dairy'],
    'minutes': 6,
  },
  {
    'name': 'Salesberry',
    'area': 'Maharajgunj, Kathmandu',
    'distance': '1.2 km',
    'open': true,
    'rating': 4.2,
    'tags': ['Meat', 'Spices', 'Grains'],
    'minutes': 14,
  },
  {
    'name': 'Civil Mall Mart',
    'area': 'Sundhara, Kathmandu',
    'distance': '2.1 km',
    'open': false,
    'rating': 4.0,
    'tags': ['Vegetables', 'Dairy', 'Snacks'],
    'minutes': 22,
  },
  {
    'name': 'Big Mart',
    'area': 'Hattisar, Kathmandu',
    'distance': '2.8 km',
    'open': true,
    'rating': 4.7,
    'tags': ['All Ingredients', 'Organic'],
    'minutes': 28,
  },
  {
    'name': 'Saleways Supermarket',
    'area': 'Lazimpat, Kathmandu',
    'distance': '3.5 km',
    'open': true,
    'rating': 3.9,
    'tags': ['Spices', 'Grains', 'Vegetables'],
    'minutes': 35,
  },
];

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  bool _isLocating = false;
  bool _locationFound = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartProvider.notifier).fetchCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _locateMe() async {
    // 1. Check & request location permission
    var status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.location_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text("Location permission denied"),
              ]),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLocating = true);

    try {
      // 2. Check if GPS is enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if (mounted) setState(() => _isLocating = false);
        return;
      }

      // 3. Get GPS fix with timeout — emulator often hangs without one
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint("[Locate] GPS timed out — using mock location");
          return Position(
            latitude: 27.7172,
            longitude: 85.3240,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        },
      );

      // 4. Show mocked Kathmandu location for demo
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationFound = true;
        });
      }
    } catch (e) {
      debugPrint("[Locate] Error: $e");
      // Fallback — still show mock marts
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationFound = true;
        });
      }
    }
  }

  List<Map> get _filteredMarts {
    if (_searchQuery.isEmpty) return List<Map>.from(_mockMarts);
    final q = _searchQuery.toLowerCase();
    return _mockMarts
        .where((m) =>
            (m['name'] as String).toLowerCase().contains(q) ||
            (m['area'] as String).toLowerCase().contains(q))
        .toList();
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress bar
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
                      value: boughtCount / cartItems.length,
                      backgroundColor: Colors.grey.shade200,
                      color: _green,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Cart items
                      ...cartItems.asMap().entries.map(
                            (e) => _cartItemCard(e.value, e.key),
                          ),

                      const SizedBox(height: 24),

                      // ── NEARBY MARTS SECTION ──
                      _buildNearbyMartsSection(),

                      const SizedBox(height: 16),
                    ],
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
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
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
                              content: const Row(children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text("Grocery list saved!"),
                              ]),
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

  // ── NEARBY MARTS SECTION ──
  Widget _buildNearbyMartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store_mall_directory_rounded,
                  color: _green, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nearby Marts",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Find stores that carry your ingredients",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Location bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _locationFound
                      ? _greenLight
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _locationFound
                      ? Icons.location_on_rounded
                      : Icons.location_searching_rounded,
                  color: _locationFound ? _green : Colors.orange.shade400,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationFound
                          ? "Naxal, Kathmandu"
                          : "Location not set",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _locationFound
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _locationFound
                          ? "Showing marts within 5 km"
                          : "Tap to detect your location",
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isLocating ? null : _locateMe,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isLocating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _locationFound ? "Update" : "Locate Me",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

        if (_locationFound) ...[
          const SizedBox(height: 12),

          // Search bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v),
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search marts by name or area...",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.close_rounded,
                          color: Colors.grey.shade400, size: 16),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Mart cards
          ..._filteredMarts.map((mart) => _buildMartCard(mart)),

          if (_filteredMarts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "No marts found for \"$_searchQuery\"",
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMartCard(Map mart) {
    final isOpen = mart['open'] as bool;
    final rating = mart['rating'] as double;
    final tags = mart['tags'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Store icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOpen ? _greenLight : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: isOpen ? _green : Colors.grey.shade400,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Name + area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mart['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 2),
                          Text(
                            mart['area'] as String,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Open/closed badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? _greenLight
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOpen ? "Open" : "Closed",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isOpen ? _green : Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Rating + distance row
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Colors.amber, size: 13),
                const SizedBox(width: 3),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                Icon(Icons.directions_walk_rounded,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(
                  "${mart['distance']} · ~${mart['minutes']} min walk",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.grey.shade200, width: 1),
                      ),
                      child: Text(
                        tag as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            // Get Directions button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.directions_rounded, size: 15),
                label: const Text("Get Directions",
                    style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(children: [
                        const Icon(Icons.navigation_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text("Opening directions to ${mart['name']}..."),
                      ]),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
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