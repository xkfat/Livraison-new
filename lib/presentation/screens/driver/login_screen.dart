//import 'package:deliverli/presentation/screens/driver/home_screen.dart';
import 'package:deliverli/presentation/screens/driver/main_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _login() async { // 1. Added async keyword (optional but cleaner)
    // 2. clear focus to close keyboard
    FocusScope.of(context).unfocus(); 

    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // 3. CRITICAL: Check if the widget is still on screen before using context
      if (!mounted) return; 

      setState(() {
        _isLoading = false;
      });

      // 4. Navigate
     Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const MainScreen()),
);
    } else {
      // Validation failed
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with back button and logo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: keyboardVisible
                  ? MediaQuery.of(context).size.height * 0.12
                  : MediaQuery.of(context).size.height * 0.32,
              width: double.infinity,
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 10,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Logo and title
                  Center(
                    child: AnimatedOpacity(
                      opacity: keyboardVisible ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Logo.png',
                            height: keyboardVisible ? 0 : 140,
                            fit: BoxFit.contain,
                          ),
                          if (!keyboardVisible) const SizedBox(height: 12),
                          if (!keyboardVisible)
                            const Text(
                              'Espace Livreur',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous pour gérer vos livraisons',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email field
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          hintText: 'exemple@email.com',
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      const Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            foregroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: AppColors.cardBackground.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Support text
                      Center(
                        child: Text(
                          'Problème de connexion ? Contactez le support.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}