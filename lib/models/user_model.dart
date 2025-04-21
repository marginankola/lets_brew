class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final List<String> favoriteCoffees;
  final String authProvider; // firebase, google, apple
  bool isAdmin; // Changed from final to allow changing admin status

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.favoriteCoffees,
    required this.authProvider,
    this.isAdmin = false,
  });

  // Create a copy of the current user with some changes
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? favoriteCoffees,
    String? authProvider,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      favoriteCoffees: favoriteCoffees ?? this.favoriteCoffees,
      authProvider: authProvider ?? this.authProvider,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'favorite_coffees': favoriteCoffees,
      'auth_provider': authProvider,
      'is_admin': isAdmin,
    };
  }

  // Create a user model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      photoURL: json['photo_url'] ?? '',
      favoriteCoffees: List<String>.from(json['favorite_coffees'] ?? []),
      authProvider: json['auth_provider'] ?? 'firebase',
      isAdmin: json['is_admin'] ?? false,
    );
  }

  // Create an empty user model
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: '',
      photoURL: '',
      favoriteCoffees: [],
      authProvider: '',
      isAdmin: false,
    );
  }

  // Add coffee to favorites
  UserModel addFavorite(String coffeeId) {
    if (!favoriteCoffees.contains(coffeeId)) {
      final newFavorites = List<String>.from(favoriteCoffees)..add(coffeeId);
      return copyWith(favoriteCoffees: newFavorites);
    }
    return this;
  }

  // Remove coffee from favorites
  UserModel removeFavorite(String coffeeId) {
    if (favoriteCoffees.contains(coffeeId)) {
      final newFavorites = List<String>.from(favoriteCoffees)..remove(coffeeId);
      return copyWith(favoriteCoffees: newFavorites);
    }
    return this;
  }
}
