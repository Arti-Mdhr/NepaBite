import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'profile_screen.dart';
import  'saved_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> recipes = [
    {
      "title": "Yomari (Khuwa Filling)",
      "time": "40 min",
      "image": "assets/images/yomari.png",
    },
    {
      "title": "Bara (Wo)",
      "time": "10 mins",
      "image": "assets/images/bara.png",
    },
  ];

  final List<Map<String, String>> newRecipes = [
    {
      "title": "MO:MO",
      "image": "assets/images/momo.png",
    },
    {
      "title": "Chatamari",
      "image": "assets/images/chataamari.png",
    },
  ];

  int selectedCategory = 0;

  late final List<Widget> lstScreens = [
    _buildHomeScreen(),
    const CartScreen(),
    const SavedRecipeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: lstScreens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1EB980),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
  Widget _buildHomeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
              child: Text(
                "Namaste,",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "What are you cooking today?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.black54),
                          SizedBox(width: 10),
                          Text(
                            "Search recipe",
                            style: TextStyle(color: Colors.black54),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFF1EB980),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildChip("All", 0),
                  _buildChip("Nepali", 1),
                  _buildChip("Newari", 2),
                  _buildChip("Street Food", 3),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return _buildRecipeCard(recipes[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "New Recipes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newRecipes.length,
                itemBuilder: (context, index) {
                  return _buildSmallRecipeCard(newRecipes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChip(String text, int index) {
    bool isSelected = selectedCategory == index;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1EB980) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1EB980)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildRecipeCard(Map<String, String> recipe) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              recipe["image"]!,
              height: 135,
              width: 175,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe["title"]!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Time: ${recipe['time']}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallRecipeCard(Map<String, String> recipe) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              recipe["image"]!,
              height: 135,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              recipe["title"]!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
