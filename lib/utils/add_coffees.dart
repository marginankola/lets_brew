import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/services/coffee_service.dart';

Future<void> addDetailedCoffees(BuildContext context) async {
  final coffeeService = Provider.of<CoffeeService>(context, listen: false);

  final coffees = [
    Coffee(
      id: 'espresso-1',
      name: 'Classic Espresso',
      description:
          'A pure and intense shot of espresso made from finely ground Arabica beans. Perfect for those who appreciate the authentic taste of coffee.',
      imageUrl: 'https://images.unsplash.com/photo-1520031607889-97e2a48baa38',
      ingredients: [
        Ingredient(name: 'Arabica Coffee Beans', amount: '18', unit: 'g'),
        Ingredient(name: 'Hot Water', amount: '36', unit: 'ml'),
      ],
      brewTime: 30,
      difficulty: 'Medium',
      type: 'Espresso',
      rating: 4.8,
      isIced: false,
      brewingSteps: [
        BrewingStep(
          description: 'Grind coffee beans to fine consistency',
          duration: 30,
        ),
        BrewingStep(description: 'Tamp ground coffee firmly', duration: 15),
        BrewingStep(description: 'Extract espresso shot', duration: 30),
      ],
    ),
    Coffee(
      id: 'latte-1',
      name: 'Vanilla Latte',
      description:
          'A smooth and creamy latte with rich vanilla flavor. Made with premium espresso and steamed milk, topped with a light layer of foam.',
      imageUrl: 'https://images.unsplash.com/photo-1582192730841-2a682d7375f9',
      ingredients: [
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Vanilla Syrup', amount: '15', unit: 'ml'),
        Ingredient(name: 'Steamed Milk', amount: '240', unit: 'ml'),
        Ingredient(name: 'Milk Foam', amount: '1', unit: 'cm'),
      ],
      brewTime: 180,
      difficulty: 'Medium',
      type: 'Latte',
      rating: 4.6,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Brew espresso shot', duration: 30),
        BrewingStep(description: 'Add vanilla syrup to cup', duration: 10),
        BrewingStep(description: 'Steam milk to 65°C', duration: 60),
        BrewingStep(
          description: 'Pour steamed milk and top with foam',
          duration: 80,
        ),
      ],
    ),
    Coffee(
      id: 'iced-1',
      name: 'Iced Caramel Macchiato',
      description:
          'A refreshing iced coffee with layers of vanilla, milk, espresso, and caramel drizzle. Perfect for hot summer days.',
      imageUrl: 'https://images.unsplash.com/photo-1581996323777-d2dacad7685d',
      ingredients: [
        Ingredient(name: 'Vanilla Syrup', amount: '15', unit: 'ml'),
        Ingredient(name: 'Cold Milk', amount: '120', unit: 'ml'),
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Ice Cubes', amount: '4-5', unit: 'pcs'),
        Ingredient(name: 'Caramel Drizzle', amount: '15', unit: 'ml'),
      ],
      brewTime: 120,
      difficulty: 'Easy',
      type: 'Iced Coffee',
      rating: 4.7,
      isIced: true,
      brewingSteps: [
        BrewingStep(description: 'Add vanilla syrup to cup', duration: 10),
        BrewingStep(description: 'Add ice cubes', duration: 10),
        BrewingStep(description: 'Pour cold milk', duration: 10),
        BrewingStep(description: 'Brew and pour espresso shot', duration: 30),
        BrewingStep(description: 'Drizzle caramel on top', duration: 60),
      ],
    ),
    Coffee(
      id: 'cold-brew-1',
      name: 'Classic Cold Brew',
      description:
          'Smooth and naturally sweet cold brew coffee made by steeping coarse ground coffee in cold water for 12-24 hours.',
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c',
      ingredients: [
        Ingredient(name: 'Coarse Ground Coffee', amount: '100', unit: 'g'),
        Ingredient(name: 'Cold Water', amount: '1', unit: 'L'),
        Ingredient(name: 'Ice Cubes', amount: '4-5', unit: 'pcs'),
      ],
      brewTime: 720,
      difficulty: 'Hard',
      type: 'Cold Brew',
      rating: 4.9,
      isIced: true,
      brewingSteps: [
        BrewingStep(description: 'Coarsely grind coffee beans', duration: 30),
        BrewingStep(
          description: 'Mix coffee grounds with cold water',
          duration: 30,
        ),
        BrewingStep(
          description: 'Steep in refrigerator for 12-24 hours',
          duration: 720,
        ),
        BrewingStep(
          description: 'Strain through fine mesh filter',
          duration: 30,
        ),
        BrewingStep(description: 'Serve over ice', duration: 10),
      ],
    ),
    Coffee(
      id: 'cappuccino-1',
      name: 'Traditional Cappuccino',
      description:
          'A classic Italian coffee drink with equal parts espresso, steamed milk, and milk foam. Perfect balance of strong coffee and creamy texture.',
      imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213',
      ingredients: [
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Steamed Milk', amount: '60', unit: 'ml'),
        Ingredient(name: 'Milk Foam', amount: '60', unit: 'ml'),
      ],
      brewTime: 180,
      difficulty: 'Hard',
      type: 'Cappuccino',
      rating: 4.8,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Brew espresso shot', duration: 30),
        BrewingStep(description: 'Steam milk to 65°C', duration: 60),
        BrewingStep(description: 'Pour steamed milk', duration: 30),
        BrewingStep(description: 'Top with thick milk foam', duration: 60),
      ],
    ),
    Coffee(
      id: 'mocha-1',
      name: 'Dark Chocolate Mocha',
      description:
          'Rich and indulgent mocha made with premium dark chocolate and espresso. Topped with whipped cream and chocolate shavings.',
      imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d',
      ingredients: [
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Dark Chocolate', amount: '20', unit: 'g'),
        Ingredient(name: 'Steamed Milk', amount: '240', unit: 'ml'),
        Ingredient(name: 'Whipped Cream', amount: '30', unit: 'ml'),
        Ingredient(name: 'Chocolate Shavings', amount: '5', unit: 'g'),
      ],
      brewTime: 210,
      difficulty: 'Medium',
      type: 'Mocha',
      rating: 4.7,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Melt dark chocolate in cup', duration: 30),
        BrewingStep(description: 'Brew espresso shot', duration: 30),
        BrewingStep(description: 'Steam milk to 65°C', duration: 60),
        BrewingStep(description: 'Pour steamed milk and stir', duration: 30),
        BrewingStep(
          description: 'Top with whipped cream and chocolate shavings',
          duration: 60,
        ),
      ],
    ),
    Coffee(
      id: 'americano-1',
      name: 'Classic Americano',
      description:
          'A clean and refreshing coffee made by diluting espresso with hot water. Perfect for those who prefer a lighter coffee experience.',
      imageUrl: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04',
      ingredients: [
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Hot Water', amount: '120', unit: 'ml'),
      ],
      brewTime: 90,
      difficulty: 'Easy',
      type: 'Americano',
      rating: 4.5,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Brew espresso shot', duration: 30),
        BrewingStep(description: 'Add hot water', duration: 60),
      ],
    ),
    Coffee(
      id: 'flat-white-1',
      name: 'Flat White',
      description:
          'A velvety smooth coffee with a thin layer of micro-foam. Made with double ristretto and steamed milk for a rich, intense flavor.',
      imageUrl: 'https://images.unsplash.com/photo-1528732263440-4dd10c9053f7',
      ingredients: [
        Ingredient(name: 'Double Ristretto', amount: '60', unit: 'ml'),
        Ingredient(name: 'Steamed Milk', amount: '120', unit: 'ml'),
        Ingredient(name: 'Micro-foam', amount: '1', unit: 'mm'),
      ],
      brewTime: 150,
      difficulty: 'Hard',
      type: 'Flat White',
      rating: 4.8,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Brew double ristretto', duration: 30),
        BrewingStep(
          description: 'Steam milk to 65°C with micro-foam',
          duration: 60,
        ),
        BrewingStep(
          description: 'Pour steamed milk with micro-foam',
          duration: 60,
        ),
      ],
    ),
    Coffee(
      id: 'iced-mocha-1',
      name: 'Iced Mocha Frappuccino',
      description:
          'A blended coffee drink with rich chocolate, espresso, and milk. Topped with whipped cream and chocolate drizzle.',
      imageUrl: 'https://images.unsplash.com/photo-1572286258217-215a037bdd4d',
      ingredients: [
        Ingredient(name: 'Espresso', amount: '30', unit: 'ml'),
        Ingredient(name: 'Chocolate Syrup', amount: '15', unit: 'ml'),
        Ingredient(name: 'Cold Milk', amount: '120', unit: 'ml'),
        Ingredient(name: 'Ice Cubes', amount: '8-10', unit: 'pcs'),
        Ingredient(name: 'Whipped Cream', amount: '30', unit: 'ml'),
        Ingredient(name: 'Chocolate Drizzle', amount: '10', unit: 'ml'),
      ],
      brewTime: 180,
      difficulty: 'Medium',
      type: 'Iced Coffee',
      rating: 4.6,
      isIced: true,
      brewingSteps: [
        BrewingStep(description: 'Brew espresso shot', duration: 30),
        BrewingStep(description: 'Add chocolate syrup to cup', duration: 10),
        BrewingStep(description: 'Add ice cubes and cold milk', duration: 20),
        BrewingStep(description: 'Blend until smooth', duration: 60),
        BrewingStep(
          description: 'Top with whipped cream and chocolate drizzle',
          duration: 60,
        ),
      ],
    ),
    Coffee(
      id: 'pour-over-1',
      name: 'Pour Over Coffee',
      description:
          'A clean and flavorful coffee made by slowly pouring hot water over ground coffee beans. Highlights the unique characteristics of the coffee.',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
      ingredients: [
        Ingredient(name: 'Medium Ground Coffee', amount: '22', unit: 'g'),
        Ingredient(name: 'Hot Water', amount: '350', unit: 'ml'),
      ],
      brewTime: 240,
      difficulty: 'Hard',
      type: 'Pour Over',
      rating: 4.7,
      isIced: false,
      brewingSteps: [
        BrewingStep(description: 'Rinse filter with hot water', duration: 30),
        BrewingStep(description: 'Add ground coffee and level', duration: 30),
        BrewingStep(description: 'Bloom coffee with 50ml water', duration: 30),
        BrewingStep(
          description: 'Slowly pour remaining water in circular motion',
          duration: 150,
        ),
      ],
    ),
  ];

  // Add each coffee to Firestore
  for (var coffee in coffees) {
    try {
      await coffeeService.addCoffee(coffee);
      print('Added coffee: ${coffee.name}');
    } catch (e) {
      print('Error adding coffee ${coffee.name}: $e');
    }
  }
}
