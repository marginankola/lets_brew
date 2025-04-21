import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/screens/coffee_detail_screen.dart';
import 'package:lets_brew/screens/gallery_screen.dart';
import 'package:lets_brew/screens/profile_screen.dart';
import 'package:lets_brew/screens/admin/admin_dashboard.dart';
import 'package:lets_brew/services/auth_service.dart';
import 'package:lets_brew/services/coffee_service.dart';
import 'package:lets_brew/services/admin_service.dart';
import 'package:lets_brew/widgets/coffee_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Coffee> _hotCoffees = [];
  List<Coffee> _icedCoffees = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCoffees();

    // Add sample coffees to Firestore if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addSampleCoffeesToFirestore();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load coffees from the service
  Future<void> _loadCoffees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final coffeeService = Provider.of<CoffeeService>(context, listen: false);

      // Get all coffees from the service
      final allCoffees = await coffeeService.getAllCoffees();

      // Filter hot and iced coffees
      final hotCoffees = allCoffees.where((coffee) => !coffee.isIced).toList();
      final icedCoffees = allCoffees.where((coffee) => coffee.isIced).toList();

      setState(() {
        _hotCoffees = hotCoffees;
        _icedCoffees = icedCoffees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading coffees: $e');
    }
  }

  // Add sample coffees to Firestore if none exist
  Future<void> _addSampleCoffeesToFirestore() async {
    try {
      final coffeeService = Provider.of<CoffeeService>(context, listen: false);

      // Get current coffees
      final currentCoffees = await coffeeService.getAllCoffees();

      // If coffees already exist, don't add more
      if (currentCoffees.isNotEmpty) {
        return;
      }

      // Add sample hot coffees
      final sampleHotCoffees = _getMockHotCoffees();
      for (var coffee in sampleHotCoffees) {
        await coffeeService.addCoffee(coffee);
      }

      // Add sample iced coffees
      final sampleIcedCoffees = _getMockIcedCoffees();
      for (var coffee in sampleIcedCoffees) {
        await coffeeService.addCoffee(coffee);
      }

      // Reload coffees
      _loadCoffees();
    } catch (e) {
      print('Error adding sample coffees: $e');
    }
  }

  // Generate mock hot coffees
  List<Coffee> _getMockHotCoffees() {
    final List<Coffee> coffees = [];

    coffees.add(
      Coffee(
        id: 'hot-1',
        name: 'Espresso',
        description:
            'A concentrated coffee brewed by forcing hot water under pressure through finely ground coffee beans.',
        imageUrl:
            'https://images.unsplash.com/photo-1520031607889-97e2a48baa38',
        ingredients: [
          Ingredient(name: 'Coffee Beans', amount: '18', unit: 'g'),
          Ingredient(name: 'Hot Water', amount: '40', unit: 'ml'),
        ],
        brewTime: 120,
        difficulty: 'Medium',
        type: 'Espresso',
        rating: 4.5,
        isIced: false,
      ),
    );

    coffees.add(
      Coffee(
        id: 'hot-2',
        name: 'Cappuccino',
        description:
            'An espresso-based coffee drink that is traditionally prepared with steamed milk foam.',
        imageUrl:
            'https://images.unsplash.com/photo-1534778101976-62847782c213',
        ingredients: [
          Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
          Ingredient(name: 'Steamed Milk', amount: '60', unit: 'ml'),
          Ingredient(name: 'Milk Foam', amount: '60', unit: 'ml'),
        ],
        brewTime: 180,
        difficulty: 'Medium',
        type: 'Milk Coffee',
        rating: 4.7,
        isIced: false,
      ),
    );

    coffees.add(
      Coffee(
        id: 'hot-3',
        name: 'Latte',
        description: 'A coffee drink made with espresso and steamed milk.',
        imageUrl:
            'https://images.unsplash.com/photo-1582192730841-2a682d7375f9',
        ingredients: [
          Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
          Ingredient(name: 'Steamed Milk', amount: '240', unit: 'ml'),
          Ingredient(name: 'Milk Foam', amount: '1', unit: 'cm'),
        ],
        brewTime: 210,
        difficulty: 'Easy',
        type: 'Milk Coffee',
        rating: 4.6,
        isIced: false,
      ),
    );

    return coffees;
  }

  // Generate mock iced coffees
  List<Coffee> _getMockIcedCoffees() {
    final List<Coffee> coffees = [];

    coffees.add(
      Coffee(
        id: 'iced-1',
        name: 'Iced Americano',
        description: 'Espresso with cold water, served over ice.',
        imageUrl:
            'https://images.unsplash.com/photo-1581996323777-d2dacad7685d',
        ingredients: [
          Ingredient(name: 'Espresso', amount: '60', unit: 'ml'),
          Ingredient(name: 'Cold Water', amount: '120', unit: 'ml'),
          Ingredient(name: 'Ice Cubes', amount: '4-5', unit: 'pcs'),
        ],
        brewTime: 150,
        difficulty: 'Easy',
        type: 'Iced Coffee',
        rating: 4.3,
        isIced: true,
      ),
    );

    coffees.add(
      Coffee(
        id: 'iced-2',
        name: 'Cold Brew',
        description:
            'Coffee made by steeping ground coffee in cold water for an extended period.',
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c',
        ingredients: [
          Ingredient(name: 'Coarse Ground Coffee', amount: '100', unit: 'g'),
          Ingredient(name: 'Cold Water', amount: '1', unit: 'L'),
        ],
        brewTime: 720,
        difficulty: 'Hard',
        type: 'Iced Coffee',
        rating: 4.8,
        isIced: true,
      ),
    );

    return coffees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkGrey,
      appBar: AppBar(
        title: Text(
          "Let's Brew",
          style: TextStyle(
            color: ThemeConstants.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCoffees,
            color: ThemeConstants.cream,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            color: ThemeConstants.cream,
          ),
          Consumer<AuthService>(
            builder: (context, authService, _) {
              return FutureBuilder<bool>(
                future: _checkIfAdmin(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboard(),
                          ),
                        );
                      },
                      color: Colors.amber,
                      tooltip: 'Admin Dashboard',
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeConstants.brown,
          labelColor: ThemeConstants.cream,
          unselectedLabelColor: ThemeConstants.lightBrown,
          tabs: const [Tab(text: 'Hot Coffees'), Tab(text: 'Iced Coffees')],
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: ThemeConstants.brown),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  // Hot coffees tab
                  _buildCoffeeList(_hotCoffees),

                  // Iced coffees tab
                  _buildCoffeeList(_icedCoffees),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ThemeConstants.darkGrey,
        selectedItemColor: ThemeConstants.brown,
        unselectedItemColor: ThemeConstants.lightBrown,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Coffees'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GalleryScreen()),
            );
          }
        },
      ),
    );
  }

  // Build the coffee list
  Widget _buildCoffeeList(List<Coffee> coffees) {
    if (coffees.isEmpty) {
      return Center(
        child: Text(
          'No coffees found',
          style: TextStyle(color: ThemeConstants.cream, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coffees.length,
      itemBuilder: (context, index) {
        final coffee = coffees[index];
        return CoffeeCard(
          coffee: coffee,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoffeeDetailScreen(coffee: coffee),
              ),
            );
          },
        );
      },
    );
  }

  // Get color based on difficulty
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.shade600;
      case 'medium':
        return Colors.orange.shade700;
      case 'hard':
        return Colors.red.shade600;
      default:
        return ThemeConstants.brown;
    }
  }

  // Helper method to build info chips
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThemeConstants.cream),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: ThemeConstants.cream, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfAdmin(BuildContext context) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    return await adminService.isUserAdmin();
  }
}
