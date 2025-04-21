import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/services/timer_service.dart';
import 'package:lets_brew/widgets/brewing_timer_widget.dart';
import 'package:lets_brew/services/user_service.dart';
import 'package:lets_brew/services/coffee_service.dart';

class CoffeeDetailScreen extends StatefulWidget {
  final Coffee coffee;
  final bool startBrewing;

  const CoffeeDetailScreen({
    super.key,
    required this.coffee,
    this.startBrewing = false,
  });

  @override
  State<CoffeeDetailScreen> createState() => _CoffeeDetailScreenState();
}

class _CoffeeDetailScreenState extends State<CoffeeDetailScreen> {
  bool _showBrewingTimer = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Debug log the coffee details
    print(
      'Detail Screen - Coffee: ${widget.coffee.id}, ${widget.coffee.name}, ImageURL: ${widget.coffee.imageUrl}',
    );

    // Start brewing immediately if requested
    if (widget.startBrewing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startBrewing();
      });
    }
    // Check if this coffee is in favorites
    _checkFavoriteStatus();
  }

  // Check if this coffee is in user's favorites
  Future<void> _checkFavoriteStatus() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final isFavorite = await userService.isCoffeeFavorite(widget.coffee.id);
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final coffeeService = Provider.of<CoffeeService>(context, listen: false);

      if (_isFavorite) {
        await userService.removeFromFavorites(
          widget.coffee.id,
          coffeeService: coffeeService,
        );
      } else {
        await userService.addToFavorites(
          widget.coffee.id,
          coffeeService: coffeeService,
        );
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? '${widget.coffee.name} added to favorites'
                : '${widget.coffee.name} removed from favorites',
          ),
          backgroundColor: _isFavorite ? ThemeConstants.brown : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Start the brewing process
  void _startBrewing() {
    setState(() {
      _showBrewingTimer = true;
    });

    final timerService = Provider.of<BrewTimerService>(context, listen: false);

    // Convert the brewing steps if available
    List<String>? brewingStepDescriptions;
    if (widget.coffee.brewingSteps.isNotEmpty) {
      brewingStepDescriptions =
          widget.coffee.brewingSteps.map((step) => step.description).toList();
    }

    timerService.startTimer(
      widget.coffee.brewTime,
      steps: brewingStepDescriptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkGrey,
      body:
          _showBrewingTimer
              ? BrewingTimerWidget(
                coffee: widget.coffee,
                onClose: () {
                  setState(() {
                    _showBrewingTimer = false;
                  });
                },
              )
              : _buildCoffeeDetailView(),
    );
  }

  Widget _buildCoffeeDetailView() {
    return CustomScrollView(
      slivers: [
        // App bar with coffee image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: ThemeConstants.darkPurple,
          iconTheme: IconThemeData(color: ThemeConstants.cream),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              widget.coffee.name,
              style: TextStyle(
                color: ThemeConstants.cream,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Coffee image
                Hero(
                  tag: 'coffee-image-${widget.coffee.id}',
                  child: Image.network(
                    _getReliableCoffeeImage(widget.coffee),
                    key: ValueKey('coffee-detail-${widget.coffee.id}'),
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: ThemeConstants.cream,
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      // Try a type-based fallback
                      return Image.network(
                        _getCoffeeImageBasedOnName(widget.coffee.name),
                        key: ValueKey('coffee-fallback-${widget.coffee.id}'),
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          // Ultimate fallback
                          return Container(
                            height: 250,
                            width: double.infinity,
                            color: ThemeConstants.darkPurple,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.coffee,
                                    size: 80,
                                    color: ThemeConstants.cream,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.coffee.name,
                                    style: TextStyle(
                                      color: ThemeConstants.cream,
                                      fontSize: 22,
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
                // Gradient overlay for better text visibility
                DecoratedBox(
                  decoration: BoxDecoration(
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
              ],
            ),
          ),
          actions: [
            // Favorite button
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : ThemeConstants.cream,
              ),
              onPressed: _toggleFavorite,
              tooltip:
                  _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            // Start brewing button
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startBrewing,
              tooltip: 'Start Brewing',
            ),
          ],
        ),

        // Coffee details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coffee type and difficulty
                Row(
                  children: [
                    Icon(
                      Icons.coffee,
                      size: 18,
                      color: ThemeConstants.lightBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.coffee.type,
                      style: TextStyle(
                        color: ThemeConstants.lightBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.equalizer,
                      size: 18,
                      color: ThemeConstants.lightBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Difficulty: ${widget.coffee.difficulty}',
                      style: TextStyle(color: ThemeConstants.lightBrown),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Brew time
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: ThemeConstants.lightBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Brewing Time: ${widget.coffee.brewTime ~/ 60}:${(widget.coffee.brewTime % 60).toString().padLeft(2, '0')} min',
                      style: TextStyle(color: ThemeConstants.lightBrown),
                    ),
                  ],
                ),

                // Rating display
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 18,
                      color: ThemeConstants.lightBrown,
                    ),
                    const SizedBox(width: 8),
                    _buildRatingStars(widget.coffee.rating),
                  ],
                ),

                const Divider(height: 32),

                // Description section
                _buildSectionTitle('Description'),
                const SizedBox(height: 8),
                Text(
                  widget.coffee.description,
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Ingredients section
                _buildSectionTitle('Ingredients'),
                const SizedBox(height: 8),
                _buildIngredientsList(),

                // Brewing steps section
                if (widget.coffee.brewingSteps.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Brewing Steps'),
                  const SizedBox(height: 8),
                  _buildBrewingStepsList(),
                ],

                const SizedBox(height: 32),

                // Start brewing button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startBrewing,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Start Brewing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.brown,
                      foregroundColor: ThemeConstants.cream,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build a section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: ThemeConstants.cream,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Build the ingredients list
  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.coffee.ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: ThemeConstants.brown),
                  const SizedBox(width: 12),
                  Text(
                    '${ingredient.amount} ${ingredient.unit} ${ingredient.name}',
                    style: TextStyle(color: ThemeConstants.cream, fontSize: 16),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Build the brewing steps list
  Widget _buildBrewingStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.coffee.brewingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ThemeConstants.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: ThemeConstants.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.description,
                          style: TextStyle(
                            color: ThemeConstants.cream,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${step.duration ~/ 60}:${(step.duration % 60).toString().padLeft(2, '0')} min',
                          style: TextStyle(
                            color: ThemeConstants.lightBrown,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Build rating stars
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData iconData;
        Color color;

        if (starValue <= rating) {
          iconData = Icons.star;
          color = Colors.amber;
        } else if (starValue - 0.5 <= rating) {
          iconData = Icons.star_half;
          color = Colors.amber;
        } else {
          iconData = Icons.star_border;
          color = Colors.amber.withOpacity(0.5);
        }

        return Icon(iconData, color: color, size: 18);
      }),
    );
  }

  // Get a reliable coffee image, ensuring we have something that works
  String _getReliableCoffeeImage(Coffee coffee) {
    // Debug print to diagnose image issues
    print(
      'Detail - Coffee ID: ${coffee.id}, Image URL: ${coffee.imageUrl}, Length: ${coffee.imageUrl.length}',
    );

    // Check for null, empty or invalid URLs
    if (coffee.imageUrl == null || coffee.imageUrl.trim().isEmpty) {
      print('Detail - Empty image URL for ${coffee.name}');
      return _getCoffeeImageBasedOnName(coffee.name);
    }

    String url = coffee.imageUrl.trim();

    // If coffee has a valid imageUrl, use it
    if (url.startsWith('http') || url.startsWith('https')) {
      // Make sure URLs are correct format for Unsplash - just use width parameter
      if (url.contains('unsplash.com') && !url.contains('?')) {
        return url + '?w=1200';
      }

      // Return the original URL
      return url;
    }

    // Otherwise, get a coffee image based on name
    String fallbackImage = _getCoffeeImageBasedOnName(coffee.name);
    print('Detail - Using fallback image for ${coffee.name}: $fallbackImage');
    return fallbackImage;
  }

  // Update the coffee type image mapping with more reliable URLs
  String _getCoffeeImageBasedOnName(String name) {
    // A collection of reliable coffee images categorized by type
    final Map<String, String> coffeeTypeImages = {
      'espresso':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=1200',
      'cappuccino':
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=1200',
      'latte':
          'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=1200',
      'americano':
          'https://images.unsplash.com/photo-1581996323777-d2dacad7685d?w=1200',
      'mocha':
          'https://images.unsplash.com/photo-1534778101976-62847782c213?w=1200',
      'iced':
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=1200',
      'cold brew':
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=1200',
      'flat white':
          'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=1200',
      'pour over':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200',
      'frappe':
          'https://images.unsplash.com/photo-1577398763022-3c0bbc82b12d?w=1200',
    };

    // Default image if no match is found
    String defaultImage =
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200';

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
}
