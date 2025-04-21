import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _photoURLController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailEditing = false;
  bool _isPasswordEditing = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _photoURLController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final profile = await userService.getUserProfile();

      setState(() {
        _nameController.text = profile['displayName'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _photoURLController.text = profile['photoURL'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      bool success = true;

      // Update display name
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty) {
        success = await userService.updateDisplayName(newName);
        if (!success) {
          throw Exception('Failed to update display name');
        }
      }

      // Update email if editing
      if (_isEmailEditing) {
        final newEmail = _emailController.text.trim();
        final currentPassword = _currentPasswordController.text;

        if (newEmail.isNotEmpty && currentPassword.isNotEmpty) {
          success = await userService.updateEmail(newEmail, currentPassword);
          if (!success) {
            throw Exception('Failed to update email');
          }
        }
      }

      // Update password if editing
      if (_isPasswordEditing) {
        final currentPassword = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;

        if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
          success = await userService.updatePassword(
            currentPassword,
            newPassword,
          );
          if (!success) {
            throw Exception('Failed to update password');
          }
        }
      }

      // Update photo URL
      final photoURL = _photoURLController.text.trim();
      if (photoURL.isNotEmpty) {
        success = await userService.updatePhotoURL(photoURL);
        if (!success) {
          throw Exception('Failed to update photo URL');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context, true); // Return with success result
    } catch (e) {
      print('Error updating profile: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkGrey,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: ThemeConstants.darkPurple,
        foregroundColor: ThemeConstants.cream,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: ThemeConstants.brown),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Profile Information'),
                      const SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(
                            Icons.person,
                            color: ThemeConstants.lightBrown,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Photo URL field
                      TextFormField(
                        controller: _photoURLController,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Profile Photo URL',
                          prefixIcon: Icon(
                            Icons.image,
                            color: ThemeConstants.lightBrown,
                          ),
                          helperText: 'Enter a URL for your profile picture',
                          helperStyle: TextStyle(
                            color: ThemeConstants.lightBrown.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email section
                      _buildSectionTitle('Email Settings'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              enabled: _isEmailEditing,
                              style: TextStyle(color: ThemeConstants.cream),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: ThemeConstants.lightBrown,
                                ),
                              ),
                              validator: (value) {
                                if (_isEmailEditing) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isEmailEditing ? Icons.close : Icons.edit,
                              color: ThemeConstants.lightBrown,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEmailEditing = !_isEmailEditing;
                                if (!_isEmailEditing) {
                                  _currentPasswordController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      if (_isEmailEditing) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          style: TextStyle(color: ThemeConstants.cream),
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: ThemeConstants.lightBrown,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: ThemeConstants.lightBrown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (_isEmailEditing) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Password section
                      _buildSectionTitle('Change Password'),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: Text(
                          'Change Password',
                          style: TextStyle(color: ThemeConstants.cream),
                        ),
                        value: _isPasswordEditing,
                        activeColor: ThemeConstants.brown,
                        onChanged: (value) {
                          setState(() {
                            _isPasswordEditing = value;
                            if (!value) {
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                      ),

                      if (_isPasswordEditing) ...[
                        const SizedBox(height: 16),

                        // Current password field
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          style: TextStyle(color: ThemeConstants.cream),
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: ThemeConstants.lightBrown,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: ThemeConstants.lightBrown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (_isPasswordEditing) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // New password field
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          style: TextStyle(color: ThemeConstants.cream),
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: ThemeConstants.lightBrown,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: ThemeConstants.lightBrown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (_isPasswordEditing) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(color: ThemeConstants.cream),
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: ThemeConstants.lightBrown,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: ThemeConstants.lightBrown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (_isPasswordEditing) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.brown,
                            foregroundColor: ThemeConstants.cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    color: ThemeConstants.cream,
                                  )
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: ThemeConstants.lightBrown,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
