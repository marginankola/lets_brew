class Coffee {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Ingredient> ingredients;
  final int brewTime; // in seconds
  final String difficulty; // Easy, Medium, Hard
  final String type; // Espresso, Latte, etc.
  final double rating;
  final bool isIced; // Whether this is an iced coffee
  final List<BrewingStep> brewingSteps; // Steps for brewing with timing

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.brewTime,
    required this.difficulty,
    required this.type,
    this.rating = 0.0,
    this.isIced = false,
    this.brewingSteps = const [],
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    try {
      // Parse ingredients from JSON
      final ingredientsList = json['ingredients'] ?? [];
      final List<Ingredient> ingredients = [];

      if (ingredientsList is List) {
        for (var item in ingredientsList) {
          if (item is Map<String, dynamic>) {
            ingredients.add(Ingredient.fromJson(item));
          }
        }
      }

      // Parse brewing steps from JSON
      final brewingStepsList = json['brewingSteps'] ?? [];
      final List<BrewingStep> brewingSteps = [];

      if (brewingStepsList is List) {
        for (var item in brewingStepsList) {
          if (item is Map<String, dynamic>) {
            brewingSteps.add(BrewingStep.fromJson(item));
          }
        }
      }

      print('Parsed ${brewingSteps.length} brewing steps from JSON');

      return Coffee(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        ingredients: ingredients,
        brewTime: json['brewTime'] ?? 180,
        difficulty: json['difficulty'] ?? 'Medium',
        type: json['type'] ?? 'Coffee',
        rating: (json['rating'] ?? 4.0).toDouble(),
        isIced: json['isIced'] ?? false,
        brewingSteps: brewingSteps,
      );
    } catch (e) {
      print('Error parsing Coffee from JSON: $e');
      // Return default coffee object on error
      return Coffee(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Error Coffee',
        description: 'Error parsing coffee data',
        imageUrl: '',
        ingredients: [],
        brewTime: 180,
        difficulty: 'Medium',
        type: 'Coffee',
        rating: 4.0,
        isIced: false,
        brewingSteps: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'brewTime': brewTime,
      'difficulty': difficulty,
      'type': type,
      'rating': rating,
      'isIced': isIced,
      'brewingSteps':
          brewingSteps.map((step) {
            print('Serializing step: ${step.description} - ${step.duration}s');
            return step.toJson();
          }).toList(),
    };
  }
}

class Ingredient {
  final String name;
  final String amount;
  final String unit; // g, ml, tbsp, etc.

  Ingredient({required this.name, required this.amount, required this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount, 'unit': unit};
  }

  @override
  String toString() {
    return '$amount $unit $name';
  }
}

class BrewingStep {
  final String description;
  final int duration; // in seconds

  BrewingStep({required this.description, required this.duration});

  factory BrewingStep.fromJson(Map<String, dynamic> json) {
    return BrewingStep(
      description: json['description'] ?? '',
      duration: json['duration'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'duration': duration};
  }
}
