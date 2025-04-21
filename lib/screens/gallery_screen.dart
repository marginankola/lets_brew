import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:http/http.dart' as http;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String _currentImageUrl = '';
  String _error = '';

  // List of alternative coffee APIs to try
  final List<String> _coffeeApis = [
    'https://coffee.alexflipnote.dev/random.json', // Primary API
    'https://foodish-api.herokuapp.com/api/images/coffee', // Backup API 1
    'https://api.sampleapis.com/coffee/hot', // Backup API 2
  ];

  @override
  void initState() {
    super.initState();
    _fetchCoffeeImage();
  }

  // Fetch a random coffee image
  Future<void> _fetchCoffeeImage() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    // Try each API in order until one works
    for (final api in _coffeeApis) {
      try {
        final imageUrl = await _fetchFromApi(api);
        if (imageUrl.isNotEmpty) {
          setState(() {
            _currentImageUrl = imageUrl;
            _isLoading = false;
          });
          return; // Successfully got an image
        }
      } catch (e) {
        print('Error fetching from $api: $e');
        // Continue to the next API
      }
    }

    // If all APIs failed, use a fallback image
    setState(() {
      _currentImageUrl =
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93';
      _isLoading = false;
      _error = 'Could not fetch from coffee APIs. Using fallback image.';
    });
  }

  // Extract image URL from different API formats
  Future<String> _fetchFromApi(String apiUrl) async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Handle different API response formats
      if (apiUrl.contains('alexflipnote')) {
        // Format: {"file": "https://coffee.alexflipnote.dev/B1U3y=sZPb_.jpg"}
        final data = json.decode(response.body);
        return data['file'] ?? '';
      } else if (apiUrl.contains('foodish-api')) {
        // Format: {"image": "https://foodish-api.herokuapp.com/images/coffee/coffee123.jpg"}
        final data = json.decode(response.body);
        return data['image'] ?? '';
      } else if (apiUrl.contains('sampleapis')) {
        // Format: array of coffee objects with title, description, etc.
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Some items might have image URLs
          for (final item in data) {
            if (item is Map<String, dynamic> && item.containsKey('image')) {
              final imageUrl = item['image'];
              if (imageUrl is String && imageUrl.isNotEmpty) {
                return imageUrl;
              }
            }
          }
          // Fall back to a static image for this API
          return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93';
        }
      }
    }

    throw Exception('Failed to load image from $apiUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Coffee Gallery'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCoffeeImage,
            tooltip: 'Refresh Image',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ThemeConstants.brown),
                    const SizedBox(height: 20),
                    Text(
                      'Brewing your coffee image...',
                      style: TextStyle(
                        color: ThemeConstants.cream,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Gallery image
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeConstants.darkGrey,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Coffee image
                            Image.network(
                              _currentImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    color: ThemeConstants.brown,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: ThemeConstants.darkPurple.withOpacity(
                                    0.5,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 60,
                                          color: ThemeConstants.cream
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Could not load image',
                                          style: TextStyle(
                                            color: ThemeConstants.cream,
                                            fontSize: 18,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _fetchCoffeeImage,
                                          child: const Text('Try Again'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Caption or error
                            if (_error.isNotEmpty)
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Text(
                                  _error,
                                  style: TextStyle(
                                    color: ThemeConstants.cream.withOpacity(
                                      0.9,
                                    ),
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.7),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Controls and info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Tap Refresh to see more coffee images',
                          style: TextStyle(
                            color: ThemeConstants.cream,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchCoffeeImage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.brown,
                            foregroundColor: ThemeConstants.cream,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
