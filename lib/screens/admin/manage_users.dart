import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/user_model.dart';
import 'package:lets_brew/services/admin_service.dart';

// Enum to define user management actions
enum UserAction { view, add, edit, delete, toggleAdmin }

class ManageUsersScreen extends StatefulWidget {
  final UserAction initialAction;

  const ManageUsersScreen({super.key, this.initialAction = UserAction.view});

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Selected user
  UserModel? _selectedUser;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();

    // If initial action is add, prepare the form
    if (widget.initialAction == UserAction.add) {
      _prepareForAddUser();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final users = await adminService.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _prepareForAddUser() {
    _clearForm();
    _isAdmin = false;
  }

  void _prepareForEditUser(UserModel user) {
    _selectedUser = user;

    // Populate form fields
    _emailController.text = user.email;
    _displayNameController.text = user.displayName;
    _passwordController.clear(); // Don't populate password for editing

    setState(() {
      _isAdmin = user.isAdmin;
    });
  }

  void _clearForm() {
    _selectedUser = null;
    _emailController.clear();
    _displayNameController.clear();
    _passwordController.clear();
    _isAdmin = false;
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      // Create a new user object
      final newUser = UserModel(
        uid: '', // Will be generated by Firebase
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        photoURL: '',
        favoriteCoffees: [],
        authProvider: 'firebase',
        isAdmin: _isAdmin,
      );

      await adminService.createUser(newUser, _passwordController.text.trim());

      if (!mounted) return;

      _showSuccessSnackBar('User added successfully');
      _clearForm();
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to add user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (_selectedUser == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      // Update the user object
      final updatedUser = _selectedUser!.copyWith(
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        isAdmin: _isAdmin,
      );

      await adminService.updateUser(updatedUser);

      if (!mounted) return;

      _showSuccessSnackBar('User updated successfully');
      _clearForm();
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to update user: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser(String uid) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.deleteUser(uid);

      if (!mounted) return;

      _showSuccessSnackBar('User deleted successfully');
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAdminStatus(UserModel user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final updatedUser = user.copyWith(isAdmin: !user.isAdmin);

      await adminService.updateUser(updatedUser);

      if (!mounted) return;

      _showSuccessSnackBar(
        user.isAdmin ? 'Admin rights removed' : 'Admin rights granted',
      );
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to update admin status: $e');
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

  // Show dialog to confirm user deletion
  Future<void> _showDeleteConfirmation(UserModel user) async {
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
                  'Are you sure you want to delete ${user.email}?',
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
                _deleteUser(user.uid);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _prepareForAddUser,
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
    // If a user is selected for editing or we're adding a new user
    if (_selectedUser != null || widget.initialAction == UserAction.add) {
      return _buildUserForm();
    }

    // Otherwise show the list of users
    return _buildUserList();
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: ThemeConstants.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: ThemeConstants.brown.withOpacity(0.3),
              radius: 24,
              backgroundImage:
                  user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : null,
              child:
                  user.photoURL.isEmpty
                      ? Icon(Icons.person, color: ThemeConstants.cream)
                      : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName
                        : user.email.split('@').first,
                    style: TextStyle(
                      color: ThemeConstants.cream,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (user.isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.brown.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: ThemeConstants.lightBrown,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: ThemeConstants.cream.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auth: ${user.authProvider.toUpperCase()} | '
                  'Favorites: ${user.favoriteCoffees.length}',
                  style: TextStyle(
                    color: ThemeConstants.lightBrown,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    user.isAdmin ? Icons.person_remove : Icons.person_add,
                    color: user.isAdmin ? Colors.red : Colors.green,
                  ),
                  onPressed: () => _toggleAdminStatus(user),
                  tooltip:
                      user.isAdmin
                          ? 'Remove admin rights'
                          : 'Grant admin rights',
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: ThemeConstants.cream),
                  onPressed: () => _prepareForEditUser(user),
                  tooltip: 'Edit user',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(user),
                  tooltip: 'Delete user',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildUserForm() {
    final isEditing = _selectedUser != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit User' : 'Add New User',
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Email field
            TextFormField(
              controller: _emailController,
              enabled: !isEditing, // Can't edit email for existing users
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: ThemeConstants.cream),
              decoration: InputDecoration(
                labelText: 'Email',
                helperText: isEditing ? 'Email cannot be changed' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: ThemeConstants.darkGrey,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Email is required';
                }
                if (!val.contains('@') || !val.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Display name field
            TextFormField(
              controller: _displayNameController,
              style: TextStyle(color: ThemeConstants.cream),
              decoration: InputDecoration(
                labelText: 'Display Name',
                helperText: 'Name displayed to other users',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: ThemeConstants.darkGrey,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Display name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field - only for adding new users
            if (!isEditing)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: ThemeConstants.cream),
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'Minimum 6 characters',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: ThemeConstants.darkGrey,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

            if (!isEditing) const SizedBox(height: 16),

            // Admin checkbox
            SwitchListTile(
              title: Text(
                'Admin Privileges',
                style: TextStyle(color: ThemeConstants.cream),
              ),
              subtitle: Text(
                'Can manage coffees and users',
                style: TextStyle(
                  color: ThemeConstants.cream.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              value: _isAdmin,
              activeColor: ThemeConstants.brown,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: ThemeConstants.darkGrey),
              ),
              tileColor: ThemeConstants.darkGrey,
              onChanged: (val) {
                setState(() {
                  _isAdmin = val;
                });
              },
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : isEditing
                        ? _updateUser
                        : _addUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update User' : 'Add User',
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            if (_selectedUser != null)
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
}
