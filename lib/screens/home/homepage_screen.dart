import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/features/recipe/domain/entity/saved_recipe_entity.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/recipe_view_model.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/saved_recipe_view_model.dart';
import 'package:nepabite/screens/recipe/recipe_detail_screen.dart';

import 'cart_screen.dart';
import 'profile_screen.dart';
import 'saved_recipe_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String _selectedCategory = "All";

  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(recipeViewModelProvider.notifier).fetchRecipes();
      ref.read(savedRecipeProvider.notifier).fetchSavedRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipeViewModelProvider);

    final screens = [
      _buildHomeScreen(recipes),
      const CartScreen(),
      const SavedRecipeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: _green,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: _selectedIndex,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_rounded),
              activeIcon: Icon(Icons.bookmark_rounded),
              label: "Saved",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen(List recipes) {
    // Categories
    final categories = ["All"];
    for (final r in recipes) {
      final cat = r.category ?? "";
      if (cat.isNotEmpty && !categories.contains(cat)) categories.add(cat);
    }

    // Top rated recipe — use fold to avoid type mismatch with reduce
    dynamic featuredRecipe;
    if (recipes.isNotEmpty) {
      featuredRecipe = recipes.fold(recipes.first, (dynamic best, dynamic r) {
        final bestRating = (best.averageRating ?? 0.0) as double;
        final rRating = (r.averageRating ?? 0.0) as double;
        return rRating > bestRating ? r : best;
      });
    }

    // Popular = top 5 by rating (excluding featured)
    final popular = [...recipes]
      ..sort((dynamic a, dynamic b) => ((b.averageRating ?? 0.0) as double)
          .compareTo((a.averageRating ?? 0.0) as double));
    final popularList = popular
        .where((r) => featuredRecipe == null || r.id != featuredRecipe.id)
        .take(5)
        .toList();

    // Filtered for grid
    final filteredRecipes = recipes.where((recipe) {
      final matchesSearch = recipe.title.toLowerCase().contains(searchQuery);
      final matchesCategory =
          _selectedCategory == "All" || recipe.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [

          // ── HEADER + SEARCH ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Namaste 👋",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "What are you cooking today?",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: _green, size: 22),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
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
                        const SizedBox(width: 14),
                        Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Search recipes...",
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => searchQuery = "");
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.grey.shade400, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── FEATURED / TOP RATED ──
                if (featuredRecipe != null && searchQuery.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.emoji_events_rounded,
                                  color: Color(0xFFE6A817), size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Top Rated",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE6A817),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFeaturedCard(featuredRecipe),
                  const SizedBox(height: 24),
                ],

                // ── POPULAR ──
                if (popularList.isNotEmpty && searchQuery.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Popular",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "See all",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: popularList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _buildPopularCard(popularList[i]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── CATEGORY CHIPS ──
                if (categories.length > 1) ...[
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _green : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── ALL RECIPES LABEL ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Recipes",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "${filteredRecipes.length} found",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── GRID ──
          recipes.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _green)),
                )
              : filteredRecipes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                  color: _greenLight, shape: BoxShape.circle),
                              child: const Icon(Icons.search_off_rounded,
                                  size: 40, color: _green),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No recipes found",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Try a different search or category",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => _buildRecipeCard(filteredRecipes[index]),
                          childCount: filteredRecipes.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  // ── FEATURED HERO CARD ──
  Widget _buildFeaturedCard(dynamic recipe) {
    final avg = (recipe.averageRating ?? 0.0).toDouble();
    ref.watch(savedRecipeProvider);
    final notifier = ref.read(savedRecipeProvider.notifier);
    final isSaved = notifier.isSaved(recipe.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _green.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                recipe.image != null
                    ? Image.network(
                        ApiEndpoints.fileUrl(recipe.image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: _greenLight),
                      )
                    : Container(color: _greenLight),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),

                // Bookmark top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleSave(recipe, notifier, isSaved),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _green,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Info bottom
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  avg > 0 ? avg.toStringAsFixed(1) : "New",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (recipe.category != null &&
                              (recipe.category as String).isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                recipe.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── POPULAR HORIZONTAL CARD ──
  Widget _buildPopularCard(dynamic recipe) {
    final avg = (recipe.averageRating ?? 0.0).toDouble();
    ref.watch(savedRecipeProvider);
    final notifier = ref.read(savedRecipeProvider.notifier);
    final isSaved = notifier.isSaved(recipe.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: recipe.image != null
                      ? Image.network(
                          ApiEndpoints.fileUrl(recipe.image),
                          height: 110,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 110,
                            color: _greenLight,
                            child: const Center(
                              child: Icon(Icons.fastfood_rounded, color: _green, size: 30),
                            ),
                          ),
                        )
                      : Container(
                          height: 110,
                          color: _greenLight,
                          child: const Center(
                            child: Icon(Icons.fastfood_rounded, color: _green, size: 30),
                          ),
                        ),
                ),
                // Rating chip on image
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          avg > 0 ? avg.toStringAsFixed(1) : "New",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleSave(recipe, notifier, isSaved),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _green,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (recipe.category != null && (recipe.category as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      recipe.category,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GRID CARD ──
  Widget _buildRecipeCard(dynamic recipe) {
    final avg = (recipe.averageRating ?? 0.0).toDouble();
    ref.watch(savedRecipeProvider);
    final notifier = ref.read(savedRecipeProvider.notifier);
    final isSaved = notifier.isSaved(recipe.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: recipe.image != null
                      ? Image.network(
                          ApiEndpoints.fileUrl(recipe.image),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: _greenLight,
                            child: const Center(
                              child: Icon(Icons.fastfood_rounded, size: 36, color: _green),
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: _greenLight,
                          child: const Center(
                            child: Icon(Icons.fastfood_rounded, size: 36, color: _green),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSave(recipe, notifier, isSaved),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _green,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (recipe.category != null && (recipe.category as String).isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.category!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  _buildRatingRow(avg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSave(dynamic recipe, dynamic notifier, bool isSaved) {
    if (isSaved) {
      notifier.removeRecipe(recipe.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.bookmark_remove, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text("Recipe removed"),
          ]),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      notifier.saveRecipe(
        SavedRecipeEntity(
          id: recipe.id,
          title: recipe.title,
          image: recipe.image,
          category: recipe.category,
          description: recipe.description,
          ingredients: List<Map<String, dynamic>>.from(recipe.ingredients ?? []),
          instructions: List<String>.from(recipe.instructions ?? []),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.bookmark_added, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text("Recipe saved!"),
          ]),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildRatingRow(double avg) {
    if (avg == 0) {
      return Row(
        children: [
          Icon(Icons.star_border_rounded, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 3),
          Text("No ratings",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ],
      );
    }
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (avg >= i + 1) {
            return const Icon(Icons.star_rounded, size: 12, color: _green);
          } else if (avg >= i + 0.5) {
            return const Icon(Icons.star_half_rounded, size: 12, color: _green);
          } else {
            return Icon(Icons.star_border_rounded, size: 12, color: Colors.grey.shade300);
          }
        }),
        const SizedBox(width: 4),
        Text(
          avg.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
      ],
    );
  }
}