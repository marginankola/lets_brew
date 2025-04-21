import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lets_brew/services/coffee_service.dart';

class UserService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Current authenticated user
  User? get currentUser => _auth.currentUser;

  // Get user's favorite coffees
  Future<List<String>> getFavoriteCoffees() async {
    try {
      // Check if user is authenticated
      if (currentUser == null) {
        return [];
      }

      // Get the user document
      final doc = await _usersCollection.doc(currentUser!.uid).get();

      // If document doesn't exist or has no favorites
      if (!doc.exists ||
          !(doc.data() as Map<String, dynamic>).containsKey(
            'favoriteCoffees',
          )) {
        return [];
      }

      // Extract favorite coffees from document
      final List<dynamic> favorites =
          (doc.data() as Map<String, dynamic>)['favoriteCoffees'] ?? [];
      return favorites.map((id) => id.toString()).toList();
    } catch (e) {
      print('Error getting favorite coffees: $e');
      return [];
    }
  }

  // Get number of users who favorited a specific coffee
  Future<int> getCoffeeLikesCount(String coffeeId) async {
    try {
      // Query all users who have this coffee in their favorites
      final querySnapshot =
          await _usersCollection
              .where('favoriteCoffees', arrayContains: coffeeId)
              .get();

      // Return the count of documents (users)
      return querySnapshot.size;
    } catch (e) {
      print('Error getting coffee likes count: $e');
      return 0;
    }
  }

  // Check if a coffee is in favorites
  Future<bool> isCoffeeFavorite(String coffeeId) async {
    try {
      final favorites = await getFavoriteCoffees();
      return favorites.contains(coffeeId);
    } catch (e) {
      print('Error checking if coffee is favorite: $e');
      return false;
    }
  }

  // Add a coffee to favorites
  Future<void> addToFavorites(
    String coffeeId, {
    CoffeeService? coffeeService,
  }) async {
    try {
      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Add to Firestore using array-union
      await _usersCollection.doc(currentUser!.uid).set({
        'favoriteCoffees': FieldValue.arrayUnion([coffeeId]),
      }, SetOptions(merge: true));

      // Update coffee rating based on favorites
      if (coffeeService != null) {
        await coffeeService.updateCoffeeRatingByFavorites(coffeeId);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove a coffee from favorites
  Future<void> removeFromFavorites(
    String coffeeId, {
    CoffeeService? coffeeService,
  }) async {
    try {
      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Remove from Firestore using array-remove
      await _usersCollection.doc(currentUser!.uid).update({
        'favoriteCoffees': FieldValue.arrayRemove([coffeeId]),
      });

      // Update coffee rating based on favorites
      if (coffeeService != null) {
        await coffeeService.updateCoffeeRatingByFavorites(coffeeId);
      }

      notifyListeners();
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Rate a coffee (1-5 stars)
  Future<void> rateCoffee(String coffeeId, double rating) async {
    try {
      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Ensure rating is within bounds
      final safeRating = rating.clamp(1.0, 5.0);

      // Store the rating in the user's ratings
      await _usersCollection.doc(currentUser!.uid).set({
        'coffeeRatings': {coffeeId: safeRating},
      }, SetOptions(merge: true));

      // Update the coffee's average rating (this would usually be done via a backend function)
      // For now, we just store the user's rating

      notifyListeners();
    } catch (e) {
      print('Error rating coffee: $e');
      rethrow;
    }
  }

  // Get user's rating for a specific coffee
  Future<double?> getCoffeeRating(String coffeeId) async {
    try {
      // Check if user is authenticated
      if (currentUser == null) {
        return null;
      }

      // Get the user document
      final doc = await _usersCollection.doc(currentUser!.uid).get();

      // If document doesn't exist or has no ratings
      if (!doc.exists ||
          !(doc.data() as Map<String, dynamic>).containsKey('coffeeRatings')) {
        return null;
      }

      // Extract ratings from document
      final Map<String, dynamic> ratings =
          (doc.data() as Map<String, dynamic>)['coffeeRatings'] ?? {};

      if (!ratings.containsKey(coffeeId)) {
        return null;
      }

      return (ratings[coffeeId] as num).toDouble();
    } catch (e) {
      print('Error getting coffee rating: $e');
      return null;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _usersCollection.doc(currentUser!.uid).get();

      if (!doc.exists) {
        // Create default profile if it doesn't exist
        final defaultProfile = {
          'displayName': currentUser!.displayName ?? 'Coffee Lover',
          'email': currentUser!.email ?? '',
          'photoURL': currentUser!.photoURL ?? '',
          'favoriteCoffees': [],
        };

        await _usersCollection.doc(currentUser!.uid).set(defaultProfile);
        return defaultProfile;
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  // Update user display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _usersCollection.doc(currentUser!.uid).update({
        'displayName': displayName,
      });

      // Also update in Firebase Auth if possible
      await currentUser!.updateDisplayName(displayName);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating display name: $e');
      return false;
    }
  }

  // Update user email
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Re-authenticate user to ensure they have the correct credentials
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await currentUser!.updateEmail(newEmail);

      // Update email in Firestore
      await _usersCollection.doc(currentUser!.uid).update({'email': newEmail});

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  // Update user password
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Re-authenticate user to ensure they have the correct credentials
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update password in Firebase Auth
      await currentUser!.updatePassword(newPassword);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Update user photo URL
  Future<bool> updatePhotoURL(String photoURL) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update photo URL in Firestore
      await _usersCollection.doc(currentUser!.uid).update({
        'photoURL': photoURL,
      });

      // Also update in Firebase Auth if possible
      await currentUser!.updatePhotoURL(photoURL);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating photo URL: $e');
      return false;
    }
  }
}
