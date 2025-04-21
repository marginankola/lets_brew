import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/services/auth_service.dart';
import 'package:lets_brew/screens/home_screen.dart';
import 'package:lets_brew/screens/signup_screen.dart';
import 'package:lets_brew/utils/app_utils.dart';
import 'package:lets_brew/services/admin_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late bool _isMockAuth;

  @override
  void initState() {
    super.initState();
    // Set default test credentials for mock authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _isMockAuth = authService.isMockAuth;

      if (_isMockAuth) {
        setState(() {
          _emailController.text = 'test@example.com';
          _passwordController.text = 'password';
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Sign in with email and password
  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final authService = Provider.of<AuthService>(context, listen: false);

      // Special case for admin login
      if (email == 'marginankola@gmail.com' && password == 'M@rgin123') {
        print('Attempting admin login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attempting admin login...')),
        );
      }

      final userCredential = await authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential != null) {
        // Check if user is admin
        final adminService = Provider.of<AdminService>(context, listen: false);
        final isAdmin = await adminService.isEmailAdmin(email);

        if (!mounted) return;

        if (isAdmin) {
          // If admin, ensure admin user exists in database
          await adminService.ensureMainAdminExists();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in as administrator')),
          );
        }

        // Navigate to home screen (whether admin or regular user)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to login. Please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle();

      if (user != null) {
        // Navigate to home screen if login successful
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Show error message if login failed
        if (!mounted) return;
        AppUtils.showSnackBar(
          context,
          'Failed to sign in with Google.',
          isError: true,
        );
      }
    } catch (e) {
      AppUtils.showSnackBar(
        context,
        'An error occurred: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sign in with Apple
  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple();

      if (user != null) {
        // Navigate to home screen if login successful
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Show error message if login failed
        if (!mounted) return;
        AppUtils.showSnackBar(
          context,
          'Failed to sign in with Apple.',
          isError: true,
        );
      }
    } catch (e) {
      AppUtils.showSnackBar(
        context,
        'An error occurred: ${e.toString()}',
        isError: true,
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
    // Check mock authentication status directly from the service
    final authService = Provider.of<AuthService>(context, listen: false);
    final isMockAuth = authService.isMockAuth;

    return Scaffold(
      backgroundColor: ThemeConstants.darkGrey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo and name
                Icon(Icons.coffee, size: 80, color: ThemeConstants.cream),
                const SizedBox(height: 24),
                Text(
                  "Let's Brew",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeConstants.lightBrown,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Mock mode notice
                if (isMockAuth)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              "Development Mode",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Using mock authentication. The app has pre-filled test credentials for you.",
                          style: TextStyle(color: ThemeConstants.cream),
                        ),
                      ],
                    ),
                  ),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: ThemeConstants.lightBrown,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: ThemeConstants.cream),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: ThemeConstants.lightBrown,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ThemeConstants.lightBrown,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: ThemeConstants.lightBrown),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                    'Sign In',
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

                const SizedBox(height: 32),

                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: ThemeConstants.lightBrown.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: ThemeConstants.lightBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: ThemeConstants.lightBrown.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google sign in button
                    _buildSocialButton(
                      onPressed: _signInWithGoogle,
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    // Apple sign in button
                    _buildSocialButton(
                      onPressed: _signInWithApple,
                      icon: Icons.apple,
                      label: 'Apple',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: ThemeConstants.lightBrown),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: ThemeConstants.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build social login buttons
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
