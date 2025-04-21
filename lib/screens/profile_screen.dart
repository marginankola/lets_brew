import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/screens/login_screen.dart';
import 'package:lets_brew/services/auth_service.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/screens/coffee_detail_screen.dart';
import 'package:lets_brew/services/coffee_service.dart';
import 'package:lets_brew/services/user_service.dart';
import 'package:lets_brew/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  List<Coffee> _favoriteCoffees = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteCoffees();
  }

  Future<void> _loadFavoriteCoffees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final coffeeService = Provider.of<CoffeeService>(context, listen: false);

      // Get user's favorite coffee IDs
      final favoriteCoffeeIds = await userService.getFavoriteCoffees();

      // Convert IDs to actual Coffee objects
      final coffees = <Coffee>[];
      for (final id in favoriteCoffeeIds) {
        final coffee = await coffeeService.getCoffeeById(id);
        if (coffee != null) {
          coffees.add(coffee);
        }
      }

      setState(() {
        _favoriteCoffees = coffees;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite coffees: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
        actions: [
          // Sign out button
          IconButton(
            icon: Icon(Icons.logout, color: ThemeConstants.cream),
            onPressed: () async {
              await authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with edit button
            _buildUserInfoSection(),

            // Favorite coffees section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Favorite Coffees',
                        style: TextStyle(
                          color: ThemeConstants.cream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: ThemeConstants.lightBrown,
                        ),
                        onPressed: _loadFavoriteCoffees,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Favorites list
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: ThemeConstants.brown,
                        ),
                      )
                      : _favoriteCoffees.isEmpty
                      ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: ThemeConstants.lightBrown.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No favorite coffees yet',
                              style: TextStyle(
                                color: ThemeConstants.lightBrown,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Heart a coffee to add it to your favorites',
                              style: TextStyle(
                                color: ThemeConstants.lightBrown.withOpacity(
                                  0.7,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _favoriteCoffees.length,
                        itemBuilder: (context, index) {
                          final coffee = _favoriteCoffees[index];
                          return _buildFavoriteCoffeeCard(coffee);
                        },
                      ),
                ],
              ),
            ),

            // App preferences section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Preferences',
                    style: TextStyle(
                      color: ThemeConstants.cream,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App version info
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        'Let\'s Brew v1.0.0',
                        style: TextStyle(
                          color: ThemeConstants.lightBrown.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCoffeeCard(Coffee coffee) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoffeeDetailScreen(coffee: coffee),
          ),
        ).then((_) => _loadFavoriteCoffees());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ThemeConstants.darkGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Coffee image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                coffee.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: ThemeConstants.darkPurple,
                    child: Icon(
                      Icons.coffee,
                      size: 40,
                      color: ThemeConstants.cream,
                    ),
                  );
                },
              ),
            ),

            // Coffee details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.name,
                      style: TextStyle(
                        color: ThemeConstants.cream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coffee.type,
                      style: TextStyle(
                        color: ThemeConstants.lightBrown,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          coffee.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: ThemeConstants.cream,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConstants.brown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            coffee.difficulty,
                            style: TextStyle(
                              color: ThemeConstants.cream,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Remove from favorites button
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                try {
                  final userService = Provider.of<UserService>(
                    context,
                    listen: false,
                  );
                  final coffeeService = Provider.of<CoffeeService>(
                    context,
                    listen: false,
                  );
                  await userService.removeFromFavorites(
                    coffee.id,
                    coffeeService: coffeeService,
                  );
                  await _loadFavoriteCoffees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${coffee.name} removed from favorites'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                } catch (e) {
                  print('Error removing from favorites: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Consumer<UserService>(
      builder: (context, userService, _) {
        final user = userService.currentUser;

        return Column(
          children: [
            const SizedBox(height: 24),

            // User avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: ThemeConstants.darkPurple,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child:
                  user?.photoURL == null
                      ? Icon(
                        Icons.person,
                        size: 50,
                        color: ThemeConstants.cream,
                      )
                      : null,
            ),

            const SizedBox(height: 16),

            // User name
            Text(
              user?.displayName ?? 'Coffee Lover',
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // User email
            Text(
              user?.email ?? '',
              style: TextStyle(color: ThemeConstants.lightBrown, fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Edit profile button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    setState(() {}); // Refresh profile
                  }
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.darkPurple,
                foregroundColor: ThemeConstants.cream,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),

            const Divider(height: 40),
          ],
        );
      },
    );
  }
}
