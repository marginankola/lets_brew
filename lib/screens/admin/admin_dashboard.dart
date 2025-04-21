import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/screens/admin/manage_coffees.dart';
import 'package:lets_brew/screens/admin/manage_users.dart';
import 'package:lets_brew/screens/admin/add_sample_coffees_screen.dart';
import 'package:lets_brew/services/admin_service.dart';
import 'package:lets_brew/services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    final adminService = Provider.of<AdminService>(context);

    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
      ),
      body: FutureBuilder<bool>(
        future: adminService.isUserAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != true) {
            return const Center(
              child: Text(
                'You don\'t have admin privileges',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ThemeConstants.brown, ThemeConstants.darkBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ThemeConstants.cream.withOpacity(0.2),
                        radius: 30,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                          color: ThemeConstants.cream,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${currentUser?.displayName ?? 'Admin'}',
                              style: TextStyle(
                                color: ThemeConstants.cream,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You have full admin privileges',
                              style: TextStyle(
                                color: ThemeConstants.cream.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.cream,
                  ),
                ),
                const SizedBox(height: 12),

                // Admin options grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAdminOptionCard(
                      context,
                      'Manage\nCoffees',
                      Icons.coffee,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCoffeesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminOptionCard(
                      context,
                      'Manage\nUsers',
                      Icons.people,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageUsersScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.cream,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick actions
                Row(
                  children: [
                    _buildQuickActionButton(
                      context,
                      'Add New Coffee',
                      Icons.add_circle_outline,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManageCoffeesScreen(
                                  initialAction: CoffeeAction.add,
                                ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Add Admin User',
                      Icons.person_add,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManageUsersScreen(
                                  initialAction: UserAction.add,
                                ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Add Sample Coffees',
                      Icons.coffee,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const AddSampleCoffeesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Backup DB',
                      Icons.backup,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeConstants.darkGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: ThemeConstants.lightBrown),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: ThemeConstants.lightBrown, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: ThemeConstants.cream, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
