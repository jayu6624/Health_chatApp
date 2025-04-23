import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'theme/app_theme.dart';
import 'theme_provider.dart';
import 'auth_service.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;
  bool _isPasswordVisible = false;

  // Animation controllers
  late TabController _tabController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        isSignUp = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Navigate to home screen
  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        // Navigation will be handled by AuthWrapper
        print('Successfully signed in: ${userCredential.user?.email}');
        navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Show alert dialog for errors
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show Toast message for authentication failure
  void showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  // Email validation
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Handle email/password sign-up
  Future<void> signUpWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showAlert('Please fill in both email and password');
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      showAlert('Please enter a valid email address');
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      showAlert('Password must be at least 6 characters');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        isLoading = false;
      });
      navigateToHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        showToast('The password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('An account already exists for that email.');
      } else {
        showToast('Authentication failed! Please try again.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast('Something went wrong. Please try again.');
    }
  }

  // Handle email/password login
  Future<void> logInWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showAlert('Please fill in both email and password');
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      showAlert('Please enter a valid email address');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        isLoading = false;
      });
      navigateToHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        showToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showToast('Incorrect password.');
      } else {
        showToast('Invalid email or password. Please try again.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App bar with theme toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "AI Chat Assistant",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Welcome text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSignUp ? "Create Account" : "Welcome Back",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isSignUp
                              ? "Sign up to start chatting with AI"
                              : "Sign in to continue your conversation",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // Auth card
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? AppTheme.backgroundDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Tab bar
                            Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.black26
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppTheme.primaryColor,
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                tabs: const [
                                  Tab(text: "Sign In"),
                                  Tab(text: "Sign Up"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Fields
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "Email",
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black45,
                                ),
                              ),
                            ),
                            if (!isSignUp) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Add forgot password functionality
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Sign in/up button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (isSignUp) {
                                          signUpWithEmailPassword();
                                        } else {
                                          logInWithEmailPassword();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        isSignUp ? "Sign Up" : "Sign In",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: isDarkMode
                                        ? Colors.white24
                                        : Colors.black12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: isDarkMode
                                        ? Colors.white24
                                        : Colors.black12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Social login
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                  height: 24.0,
                                ),
                                label: const Text("Continue with Google"),
                                onPressed: _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: AppTheme.secondaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
