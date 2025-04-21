import 'package:flutter/material.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/utils/add_coffees.dart';

class AddSampleCoffeesScreen extends StatelessWidget {
  const AddSampleCoffeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Add Sample Coffees'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add 10 Detailed Coffee Recipes',
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await addDetailedCoffees(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully added sample coffees!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding coffees: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.brown,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                'Add Coffees',
                style: TextStyle(color: ThemeConstants.cream, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
