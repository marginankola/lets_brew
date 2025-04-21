import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/services/admin_service.dart';

// Enum to define coffee management actions
enum CoffeeAction { view, add, edit, delete }

class ManageCoffeesScreen extends StatefulWidget {
  final CoffeeAction initialAction;

  const ManageCoffeesScreen({super.key, this.initialAction = CoffeeAction.view});

  @override
  _ManageCoffeesScreenState createState() => _ManageCoffeesScreenState();
}

class _ManageCoffeesScreenState extends State<ManageCoffeesScreen> {
  bool _isLoading = true;
  List<Coffee> _coffees = [];
  final _formKey = GlobalKey<FormState>();

  // Controllers for coffee form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _brewTimeMinutesController =
      TextEditingController();
  final TextEditingController _brewTimeSecondsController =
      TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  double _rating = 4.0;
  bool _isIced = false;

  // For ingredients
  List<Map<String, String>> _ingredients = [];

  // For brewing steps
  List<BrewingStep> _brewingSteps = [];

  // Currently selected coffee
  Coffee? _selectedCoffee;

  @override
  void initState() {
    super.initState();
    _loadCoffees();

    // If initial action is add, prepare the form
    if (widget.initialAction == CoffeeAction.add) {
      _prepareForAddCoffee();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _imageUrlController.dispose();
    _brewTimeMinutesController.dispose();
    _brewTimeSecondsController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  Future<void> _loadCoffees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final coffees = await adminService.getAllCoffees();

      setState(() {
        _coffees = coffees;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load coffees: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _prepareForAddCoffee() {
    _clearForm();
    _ingredients = [
      {'name': '', 'amount': '', 'unit': ''},
    ];
    _brewingSteps = [BrewingStep(description: '', duration: 30)];

    // Set default values
    _difficultyController.text = 'Medium';
    _rating = 4.0;
    _brewTimeMinutesController.text = '3';
    _brewTimeSecondsController.text = '00';
    _isIced = false;
  }

  void _prepareForEditCoffee(Coffee coffee) {
    print('Preparing to edit coffee: ${coffee.id}');
    setState(() {
      _selectedCoffee = coffee;

      // Populate form fields
      _nameController.text = coffee.name;
      _descriptionController.text = coffee.description;
      _typeController.text = coffee.type;
      _imageUrlController.text = coffee.imageUrl;

      // Set minutes and seconds
      int minutes = coffee.brewTime ~/ 60;
      int seconds = coffee.brewTime % 60;
      _brewTimeMinutesController.text = minutes.toString();
      _brewTimeSecondsController.text = seconds.toString().padLeft(2, '0');

      _difficultyController.text = coffee.difficulty;
      _rating = coffee.rating;
      _isIced = coffee.isIced;

      // Populate ingredients
      _ingredients =
          coffee.ingredients
              .map((i) => {'name': i.name, 'amount': i.amount, 'unit': i.unit})
              .toList();

      // If no ingredients, add an empty one
      if (_ingredients.isEmpty) {
        _ingredients = [
          {'name': '', 'amount': '', 'unit': ''},
        ];
      }

      // Populate brewing steps
      _brewingSteps = coffee.brewingSteps.toList();

      // If no brewing steps, add an empty one
      if (_brewingSteps.isEmpty) {
        _brewingSteps = [BrewingStep(description: '', duration: 30)];
      }
    });
  }

  void _clearForm() {
    _selectedCoffee = null;
    _nameController.clear();
    _descriptionController.clear();
    _typeController.clear();
    _imageUrlController.clear();
    _brewTimeMinutesController.clear();
    _brewTimeSecondsController.clear();
    _difficultyController.clear();
    _rating = 4.0;
    _isIced = false;
    _ingredients = [];
    _brewingSteps = [];
  }

  // Calculate brew time in seconds from the fields
  int _calculateBrewTimeInSeconds() {
    final minutes = int.tryParse(_brewTimeMinutesController.text) ?? 0;
    final seconds = int.tryParse(_brewTimeSecondsController.text) ?? 0;
    return (minutes * 60) + seconds;
  }

  // Calculate total brewing steps duration
  int _calculateTotalBrewingStepsDuration() {
    int totalDuration = 0;
    for (var step in _brewingSteps) {
      totalDuration += step.duration;
    }
    return totalDuration;
  }

  // Update brew time based on brewing steps duration
  void _updateBrewTimeFromSteps() {
    final totalStepsDuration = _calculateTotalBrewingStepsDuration();
    final currentBrewTime = _calculateBrewTimeInSeconds();

    print('Current brew time: $currentBrewTime seconds');
    print('Total brewing steps duration: $totalStepsDuration seconds');

    // Only update if steps duration is longer than current brew time
    if (totalStepsDuration > currentBrewTime) {
      print(
        'Updating brew time to match steps duration: $totalStepsDuration seconds',
      );
      final minutes = totalStepsDuration ~/ 60;
      final seconds = totalStepsDuration % 60;

      setState(() {
        _brewTimeMinutesController.text = minutes.toString();
        _brewTimeSecondsController.text = seconds.toString().padLeft(2, '0');
      });
    }
  }

  // Update a brewing step's duration
  void _updateBrewingStepDuration(int index, int minutes, int seconds) {
    try {
      int duration = (minutes * 60) + seconds;
      setState(() {
        _brewingSteps[index] = BrewingStep(
          description: _brewingSteps[index].description,
          duration: duration,
        );
      });

      // Check if we need to update the overall brew time
      _updateBrewTimeFromSteps();
    } catch (e) {
      print('Error updating brewing step duration: $e');
    }
  }

  Future<void> _addCoffee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      // Create a new coffee object
      final newCoffee = Coffee(
        id: 'coffee-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text,
        type: _typeController.text,
        imageUrl: _imageUrlController.text,
        brewTime: _calculateBrewTimeInSeconds(),
        difficulty: _difficultyController.text,
        rating: _rating,
        isIced: _isIced,
        ingredients:
            _ingredients
                .where((i) => i['name']!.isNotEmpty)
                .map(
                  (i) => Ingredient(
                    name: i['name']!,
                    amount: i['amount']!,
                    unit: i['unit']!,
                  ),
                )
                .toList(),
        brewingSteps:
            _brewingSteps.where((s) => s.description.isNotEmpty).toList(),
      );

      await adminService.addCoffee(newCoffee);

      if (!mounted) return;

      _showSuccessSnackBar('Coffee added successfully');
      _clearForm();
      _loadCoffees();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to add coffee: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateCoffee() async {
    if (_selectedCoffee == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      print('Updating coffee with ID: ${_selectedCoffee!.id}');
      print('Brewing steps count: ${_brewingSteps.length}');

      // Debug brewing steps
      for (int i = 0; i < _brewingSteps.length; i++) {
        print(
          'Step ${i + 1}: ${_brewingSteps[i].description} - ${_brewingSteps[i].duration} seconds',
        );
      }

      // Clean ingredients and brewing steps of empty entries
      final validIngredients =
          _ingredients
              .where((i) => i['name']!.isNotEmpty)
              .map(
                (i) => Ingredient(
                  name: i['name']!,
                  amount: i['amount']!,
                  unit: i['unit']!,
                ),
              )
              .toList();

      final validBrewingSteps =
          _brewingSteps.where((s) => s.description.isNotEmpty).toList();

      print('Valid brewing steps count: ${validBrewingSteps.length}');

      // Update the coffee object
      final updatedCoffee = Coffee(
        id: _selectedCoffee!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        type: _typeController.text,
        imageUrl: _imageUrlController.text,
        brewTime: _calculateBrewTimeInSeconds(),
        difficulty: _difficultyController.text,
        rating: _rating,
        isIced: _isIced,
        ingredients: validIngredients,
        brewingSteps: validBrewingSteps,
      );

      print(
        'Updated coffee object: ${updatedCoffee.name}, with ${updatedCoffee.brewingSteps.length} brewing steps',
      );

      await adminService.updateCoffee(updatedCoffee);

      if (!mounted) return;

      _showSuccessSnackBar('Coffee updated successfully');
      _clearForm();
      _loadCoffees();
    } catch (e) {
      if (!mounted) return;
      print('Error updating coffee: $e');
      _showErrorSnackBar('Failed to update coffee: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCoffee(String coffeeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.deleteCoffee(coffeeId);

      if (!mounted) return;

      _showSuccessSnackBar('Coffee deleted successfully');
      _loadCoffees();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete coffee: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addIngredientField() {
    setState(() {
      _ingredients.add({'name': '', 'amount': '', 'unit': ''});
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  // Show dialog to confirm coffee deletion
  Future<void> _showDeleteConfirmation(Coffee coffee) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeConstants.darkGrey,
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: ThemeConstants.cream),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete "${coffee.name}"?',
                  style: TextStyle(color: ThemeConstants.cream),
                ),
                const SizedBox(height: 10),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    color: ThemeConstants.cream.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: ThemeConstants.cream),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCoffee(coffee.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Add a new brewing step field
  void _addBrewingStepField() {
    setState(() {
      _brewingSteps.add(BrewingStep(description: '', duration: 30));
    });

    // Check if we need to update the overall brew time
    _updateBrewTimeFromSteps();
  }

  // Remove a brewing step field
  void _removeBrewingStepField(int index) {
    setState(() {
      _brewingSteps.removeAt(index);
    });

    // Check if we need to update the overall brew time
    _updateBrewTimeFromSteps();
  }

  // Update a brewing step's description
  void _updateBrewingStepDescription(int index, String description) {
    setState(() {
      _brewingSteps[index] = BrewingStep(
        description: description,
        duration: _brewingSteps[index].duration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Coffees'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _prepareForAddCoffee();
              });
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    // If a coffee is selected for editing or we're adding a new coffee
    if (_selectedCoffee != null || widget.initialAction == CoffeeAction.add) {
      return _buildCoffeeForm();
    }

    // Otherwise show the list of coffees
    return _buildCoffeeList();
  }

  Widget _buildCoffeeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _coffees.length,
      itemBuilder: (context, index) {
        final coffee = _coffees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: ThemeConstants.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading:
                coffee.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        coffee.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (ctx, e, s) => Container(
                              width: 60,
                              height: 60,
                              color: ThemeConstants.brown.withOpacity(0.3),
                              child: Icon(
                                Icons.coffee,
                                color: ThemeConstants.cream,
                              ),
                            ),
                      ),
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ThemeConstants.brown.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.coffee, color: ThemeConstants.cream),
                    ),
            title: Text(
              coffee.name,
              style: TextStyle(
                color: ThemeConstants.cream,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  coffee.type,
                  style: TextStyle(
                    color: ThemeConstants.lightBrown,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coffee.description.length > 60
                      ? '${coffee.description.substring(0, 60)}...'
                      : coffee.description,
                  style: TextStyle(
                    color: ThemeConstants.cream.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: ThemeConstants.cream),
                  onPressed: () => _prepareForEditCoffee(coffee),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(coffee),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildCoffeeForm() {
    final isEditing = _selectedCoffee != null;

    // Define coffee types
    final coffeeTypes = [
      'Espresso',
      'Filter',
      'Cold Brew',
      'Iced Coffee',
      'Latte',
      'Cappuccino',
      'Americano',
      'Macchiato',
      'Mocha',
      'Flat White',
    ];

    // Define difficulty levels
    final difficultyLevels = ['Easy', 'Medium', 'Hard'];

    // Define common unit types
    final unitTypes = ['g', 'ml', 'oz', 'tbsp', 'tsp', 'cup', 'piece(s)'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Coffee' : 'Add New Coffee',
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Basic info section
            _buildSectionTitle('Basic Information'),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Coffee type dropdown and iced toggle
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                        coffeeTypes.contains(_typeController.text)
                            ? _typeController.text
                            : null,
                    decoration: InputDecoration(
                      labelText: 'Coffee Type',
                      filled: true,
                      fillColor: ThemeConstants.darkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: ThemeConstants.cream),
                    dropdownColor: ThemeConstants.darkGrey,
                    items:
                        coffeeTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _typeController.text = value!;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iced Coffee?',
                      style: TextStyle(
                        color: ThemeConstants.lightBrown,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _isIced,
                      onChanged: (value) {
                        setState(() {
                          _isIced = value;
                        });
                      },
                      activeColor: ThemeConstants.lightPurple,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Media section
            _buildSectionTitle('Media'),
            _buildTextField(
              controller: _imageUrlController,
              label: 'Image URL',
              helperText: 'URL to an image of the coffee',
            ),

            const SizedBox(height: 24),

            // Brewing details section
            _buildSectionTitle('Brewing Details'),

            // Brew time (minutes and seconds)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _brewTimeMinutesController,
                    label: 'Minutes',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(val) == null) {
                        return 'Must be a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _brewTimeSecondsController,
                    label: 'Seconds',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(val) == null) {
                        return 'Must be a number';
                      }
                      final seconds = int.parse(val);
                      if (seconds < 0 || seconds > 59) {
                        return 'Between 0-59';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Difficulty dropdown
            DropdownButtonFormField<String>(
              value:
                  difficultyLevels.contains(_difficultyController.text)
                      ? _difficultyController.text
                      : 'Medium',
              decoration: InputDecoration(
                labelText: 'Difficulty',
                filled: true,
                fillColor: ThemeConstants.darkGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(color: ThemeConstants.cream),
              dropdownColor: ThemeConstants.darkGrey,
              items:
                  difficultyLevels.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _difficultyController.text = value!;
                });
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please select a difficulty';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Rating with stars
            Row(
              children: [
                Text(
                  'Rating:',
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Stars for visual rating
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                // Direct numeric input for precise rating
                Row(
                  children: [
                    const Text(
                      'Set exact rating:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: _rating.toString(),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          hintText: '1.0 - 5.0',
                          hintStyle: TextStyle(color: Colors.white38),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          final parsedValue = double.tryParse(value);
                          if (parsedValue != null &&
                              parsedValue >= 1 &&
                              parsedValue <= 5) {
                            setState(() {
                              _rating = parsedValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

            const SizedBox(height: 24),

            // Ingredients section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Ingredients'),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                  onPressed: _addIngredientField,
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeConstants.lightBrown,
                  ),
                ),
              ],
            ),

            // Ingredients list
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: ingredient['name'],
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Ingredient',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: ThemeConstants.darkGrey,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _ingredients[index]['name'] = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: ingredient['amount'],
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: ThemeConstants.darkGrey,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            _ingredients[index]['amount'] = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value:
                            unitTypes.contains(ingredient['unit'])
                                ? ingredient['unit']
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: ThemeConstants.darkGrey,
                        ),
                        style: TextStyle(color: ThemeConstants.cream),
                        dropdownColor: ThemeConstants.darkGrey,
                        items:
                            unitTypes.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _ingredients[index]['unit'] = value!;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeIngredientField(index),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Brewing steps section
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Brewing Steps'),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                  onPressed: _addBrewingStepField,
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeConstants.lightBrown,
                  ),
                ),
              ],
            ),

            // Brew steps list
            ..._brewingSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;

              // Calculate minutes and seconds for display
              final minutes = step.duration ~/ 60;
              final seconds = step.duration % 60;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeConstants.darkGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeConstants.lightPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
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
                            child: Text(
                              'Step ${index + 1}',
                              style: TextStyle(
                                color: ThemeConstants.cream,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeBrewingStepField(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: step.description,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Step Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: ThemeConstants.darkGrey.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        onChanged:
                            (val) => _updateBrewingStepDescription(index, val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Duration:',
                            style: TextStyle(
                              color: ThemeConstants.lightBrown,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: minutes.toString(),
                                    style: TextStyle(
                                      color: ThemeConstants.cream,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Minutes',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: ThemeConstants.darkGrey
                                          .withOpacity(0.7),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final min = int.tryParse(val) ?? 0;
                                      _updateBrewingStepDuration(
                                        index,
                                        min,
                                        seconds,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ':',
                                  style: TextStyle(
                                    color: ThemeConstants.cream,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: seconds.toString().padLeft(
                                      2,
                                      '0',
                                    ),
                                    style: TextStyle(
                                      color: ThemeConstants.cream,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Seconds',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: ThemeConstants.darkGrey
                                          .withOpacity(0.7),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final sec = int.tryParse(val) ?? 0;
                                      _updateBrewingStepDuration(
                                        index,
                                        minutes,
                                        sec,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : isEditing
                        ? _updateCoffee
                        : _addCoffee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update Coffee' : 'Add Coffee',
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            if (_selectedCoffee != null)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _clearForm();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: ThemeConstants.cream),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: ThemeConstants.lightBrown,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: ThemeConstants.cream),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: TextStyle(
          color: ThemeConstants.cream.withOpacity(0.5),
          fontSize: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: ThemeConstants.darkGrey,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
