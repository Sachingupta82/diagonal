import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../screens/category_screen.dart';

class CategorySheet extends StatelessWidget {
  const CategorySheet({super.key});

  static const List<Map<String, String>> categories = [
    {"category": "Kerala", "cnt": "5385"},
    {"category": "Karnataka", "cnt": "4935"},
    {"category": "Andhra Pradesh", "cnt": "3875"},
    {"category": "India", "cnt": "3017"},
    {"category": "World", "cnt": "2978"},
    {"category": "Telangana", "cnt": "2596"},
    {"category": "Tamil Nadu", "cnt": "2432"},
    {"category": "Madurai", "cnt": "2163"},
    {"category": "Coimbatore", "cnt": "1814"},
    {"category": "Chennai", "cnt": "1743"},
    {"category": "Tiruchirapalli", "cnt": "1118"},
    {"category": "Technology", "cnt": "1088"},
    {"category": "Delhi", "cnt": "1081"},
    {"category": "Hyderabad", "cnt": "1036"},
    {"category": "Cricket", "cnt": "959"},
    {"category": "Mangaluru", "cnt": "894"},
    {"category": "Visakhapatnam", "cnt": "838"},
    {"category": "Movies", "cnt": "772"},
    {"category": "Business", "cnt": "684"},
    {"category": "Bihar Assembly", "cnt": "560"},
    {"category": "Bengaluru", "cnt": "534"},
    {"category": "Health", "cnt": "488"},
    {"category": "Puducherry", "cnt": "455"},
    {"category": "Videos", "cnt": "453"},
    {"category": "Sport", "cnt": "419"},
    {"category": "Races", "cnt": "407"},
    {"category": "Maharashtra", "cnt": "387"},
    {"category": "Editorial", "cnt": "383"},
    {"category": "Industry", "cnt": "379"},
    {"category": "Education", "cnt": "368"},
    {"category": "West Bengal", "cnt": "360"},
    {"category": "Markets", "cnt": "343"},
    {"category": "Science", "cnt": "312"},
    {"category": "Jammu and Kashmir", "cnt": "294"},
    {"category": "Comment", "cnt": "290"},
    {"category": "Other Sports", "cnt": "290"},
    {"category": "PR Release", "cnt": "279"},
    {"category": "Uttar Pradesh", "cnt": "278"},
    {"category": "Environment", "cnt": "255"},
    {"category": "Mumbai", "cnt": "252"},
    {"category": "Economy", "cnt": "243"},
    {"category": "News", "cnt": "237"},
    {"category": "Assam", "cnt": "230"},
    {"category": "Football", "cnt": "193"},
    {"category": "Entertainment", "cnt": "183"},
    {"category": "Children", "cnt": "172"},
    {"category": "Books", "cnt": "157"},
    {"category": "Life & Style", "cnt": "155"},
    {"category": "Archives", "cnt": "154"},
    {"category": "Odisha", "cnt": "152"},
  ];

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('tech') || cat.contains('science')) {
      return Icons.computer;
    } else if (cat.contains('sport') || cat.contains('cricket') || cat.contains('football')) {
      return Icons.sports;
    } else if (cat.contains('business') || cat.contains('market') || cat.contains('economy')) {
      return Icons.business;
    } else if (cat.contains('health')) {
      return Icons.health_and_safety;
    } else if (cat.contains('world') || cat.contains('india')) {
      return Icons.public;
    } else if (cat.contains('entertainment') || cat.contains('movies')) {
      return Icons.movie;
    } else if (cat.contains('education')) {
      return Icons.school;
    } else if (cat.contains('environment')) {
      return Icons.nature;
    }
    return Icons.article;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1E3D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Categories list
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryScreen(
                                  category: category['category']!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A1E3D).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category['category']!),
                                    color: const Color(0xFF0A1E3D),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    category['category']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A1E3D),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A1E3D).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category['cnt']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A1E3D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}