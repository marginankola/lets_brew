import 'package:flutter/material.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/services/user_service.dart';

class CoffeeCard extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback onTap;
  final bool showRating;
  final double height;
  final bool showBrewButton;

  const CoffeeCard({
    super.key,
    required this.coffee,
    required this.onTap,
    this.showRating = true,
    this.height = 280,
    this.showBrewButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height + 50, // Make card taller to give more space to the image
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: ThemeConstants.darkGrey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coffee image with overlay
            Expanded(
              flex: 4, // Increase image area proportion
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: ThemeConstants.darkPurple,
                      child: Hero(
                        tag: 'coffee-image-${coffee.id}',
                        child: Image.network(
                          _getReliableCoffeeImage(coffee),
                          key: ValueKey('coffee-card-${coffee.id}'),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: ThemeConstants.cream,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Try a type-based fallback
                            return Image.network(
                              _getCoffeeImageBasedOnName(coffee.name),
                              key: ValueKey(
                                'coffee-card-fallback-${coffee.id}',
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Ultimate fallback
                                return Container(
                                  color: ThemeConstants.darkPurple,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.coffee,
                                          size: 50,
                                          color: ThemeConstants.cream,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          coffee.name,
                                          style: TextStyle(
                                            color: ThemeConstants.cream,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Iced badge if applicable
                  if (coffee.isIced)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.ac_unit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                  // Difficulty badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(coffee.difficulty),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            coffee.difficulty.toLowerCase() == 'easy'
                                ? Icons.grade
                                : coffee.difficulty.toLowerCase() == 'medium'
                                ? Icons.trending_up
                                : Icons.whatshot,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coffee.difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Coffee name and rating
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Coffee name on left
                        Expanded(
                          child: Text(
                            coffee.name,
                            style: TextStyle(
                              color: ThemeConstants.cream,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Rating and likes on right
                        if (showRating)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeConstants.brown.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  coffee.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Consumer<UserService>(
                                  builder: (context, userService, _) {
                                    return FutureBuilder<int>(
                                      future: userService.getCoffeeLikesCount(
                                        coffee.id,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data! > 0) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.favorite,
                                                size: 12,
                                                color: Colors.redAccent,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${snapshot.data}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Coffee details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coffee type and brew time
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.coffee,
                          text: coffee.type,
                          color: ThemeConstants.darkPurple.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.timer,
                          text:
                              '${coffee.brewTime ~/ 60}:${(coffee.brewTime % 60).toString().padLeft(2, '0')} min',
                          color: ThemeConstants.darkPurple.withOpacity(0.7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description preview
                    Text(
                      coffee.description,
                      style: TextStyle(
                        color: ThemeConstants.cream.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Start brewing button if enabled
                    if (showBrewButton)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text(
                            'Brew Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.brown,
                            foregroundColor: ThemeConstants.cream,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build info chip
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThemeConstants.cream),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: ThemeConstants.cream,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Get difficulty color
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get a consistent coffee image based on coffee name
  String _getCoffeeImageBasedOnName(String name) {
    // A collection of reliable coffee images categorized by type
    final Map<String, String> coffeeTypeImages = {
      'espresso':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800',
      'cappuccino':
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=800',
      'latte':
          'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=800',
      'americano':
          'https://images.unsplash.com/photo-1581996323777-d2dacad7685d?w=800',
      'mocha':
          'https://images.unsplash.com/photo-1534778101976-62847782c213?w=800',
      'iced':
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=800',
      'cold brew':
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800',
      'flat white':
          'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=800',
      'pour over':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      'frappe':
          'https://images.unsplash.com/photo-1577398763022-3c0bbc82b12d?w=800',
    };

    // Default image if no match is found
    String defaultImage =
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800';

    // Check if the coffee name contains any of the coffee types
    String lowercaseName = name.toLowerCase();
    String matchedType = coffeeTypeImages.keys.firstWhere(
      (type) => lowercaseName.contains(type),
      orElse: () => '',
    );

    return matchedType.isNotEmpty
        ? coffeeTypeImages[matchedType]!
        : defaultImage;
  }

  // Get a reliable coffee image, ensuring we have something that works
  String _getReliableCoffeeImage(Coffee coffee) {
    // Debug print to diagnose image issues
    print(
      'Card - Coffee ID: ${coffee.id}, Image URL: ${coffee.imageUrl}, Length: ${coffee.imageUrl.length}',
    );

    // Check for null, empty or invalid URLs
    if (coffee.imageUrl == null || coffee.imageUrl.trim().isEmpty) {
      print('Card - Empty image URL for ${coffee.name}');
      return _getCoffeeImageBasedOnName(coffee.name);
    }

    String url = coffee.imageUrl.trim();

    // If coffee has a valid imageUrl, use it
    if (url.startsWith('http') || url.startsWith('https')) {
      // Make sure URLs are correct format for Unsplash - just use width parameter
      if (url.contains('unsplash.com') && !url.contains('?')) {
        return url + '?w=800';
      }
      // Return the original URL
      return url;
    }

    // Otherwise, get a coffee image based on name
    String fallbackImage = _getCoffeeImageBasedOnName(coffee.name);
    print('Card - Using fallback image for ${coffee.name}: $fallbackImage');
    return fallbackImage;
  }
}
