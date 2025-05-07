import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Call Supabase sign in
        final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // If successful (no exception thrown), proceed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Login Successful'), // Changed to destructive for visibility
              description: Text('Welcome back, ${res.user?.email ?? 'user'}!'), // Show user email
            ),
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
        }
      } on AuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Show error toast
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Login Failed'),
              description: Text(e.message), // Show Supabase error message
            ),
          );
        }
      } catch (e) {
        // Handle other potential errors
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('An Error Occurred'),
              description: Text(e.toString()),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient - matches onboarding style
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeProvider.primaryBlue.withOpacity(0.1),
                  ThemeProvider.secondaryPurple.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Main content with a single parent animation
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48), // Reduced top spacing
                    // Centered App logo with pulse animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeProvider.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people_alt_outlined,
                            size: 48,
                            color: ThemeProvider.primaryBlue,
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        ).scaleXY(
                          begin: 1,
                          end: 1.05,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ).then().scaleXY(
                          begin: 1.05,
                          end: 1,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Slightly reduced spacing
                    
                    // Login form card
                    ShadCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ShadForm(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Welcome text moved here, centered
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeProvider.primaryBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue to your circles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              
                              // Email input
                              ShadInputFormField(
                                id: 'email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                placeholder: const Text('Email'),
                                leading: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Password input
                              ShadInputFormField(
                                id: 'password',
                                controller: _passwordController,
                                placeholder: const Text('Password'),
                                obscureText: _obscurePassword,
                                leading: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.lock_outline),
                                ),
                                trailing: ShadButton(
                                  padding: EdgeInsets.zero,
                                  decoration: const ShadDecoration(
                                    secondaryBorder: ShadBorder.none,
                                    secondaryFocusedBorder: ShadBorder.none,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Remember me checkbox and forgot password
                              Row(
                                children: [
                                  ShadCheckbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Remember me'),
                                  
                                  const Spacer(),
                                  
                                  // Forgot password link
                                  ShadButton.ghost(
                                    onPressed: () {
                                      // Navigate to password reset screen
                                    },
                                    padding: EdgeInsets.zero,
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ShadButton(
                                  onPressed: _isLoading ? null : _login,
                                  leading: _isLoading 
                                    ? SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      )
                                    : null,
                                  child: Text(_isLoading ? 'Please wait' : 'Log in'),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Divider with "or" text
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Google sign in button
                              SizedBox(
                                width: double.infinity,
                                child: ShadButton.outline(
                                  onPressed: () {
                                    // Handle Google sign in - for now just simulate successful login
                                    _login();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.g_translate, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Continue with Google'),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Skip to Home button
                              SizedBox(
                                width: double.infinity,
                                child: ShadButton.secondary(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  },
                                  child: const Text('Skip Login & Go to Home'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      duration: 800.ms,
                      curve: Curves.easeOut,
                      delay: 200.ms,
                    ).moveY(
                      begin: 30,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                      delay: 200.ms,
                    ),
                    
                    const SizedBox(height: 120), // Reduced offset to move form card up
                    
                    // Don't have an account? Sign up button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        ShadButton.link(
                          onPressed: () {
                            // Navigate to registration screen
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: ThemeProvider.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(
                      duration: 800.ms,
                      curve: Curves.easeOut,
                      delay: 400.ms,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                )
                // Apply a single parent animation to entire login form
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .moveY(begin: 20, end: 0, duration: 800.ms, curve: Curves.easeOut),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to scale gradient colors
extension GradientExtension on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(factor)).toList(),
      begin: begin,
      end: end,
      stops: stops,
      transform: transform,
    );
  }
} 