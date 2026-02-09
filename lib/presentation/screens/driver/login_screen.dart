import 'package:deliverli/presentation/screens/client/client_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/auth/auth_cubit.dart';
import '../../../logic/cubit/auth/auth_state.dart';
import './main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _hasNavigated = false; // ✅ Prevent double navigation

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && !_hasNavigated) {
            // ✅ ONLY navigate on successful authentication
            _hasNavigated = true;
            print('✅ Login Screen: Authentication successful, navigating...');
            
            // Navigate based on user role
            final user = state.user;
            print('👤 User Role: ${user.role}'); 
  print('🏎️ Is Driver: ${user.isDriver}');
            if (user.isDriver) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            } else {
              _hasNavigated = false; 
      _showErrorDialog("Accès refusé : Vous n'êtes pas un livreur.");
    }
          } else if (state is AuthError) {
        _hasNavigated = false;
    _showErrorDialog(state.message);
  }
},
        builder: (context, state) {
          final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

          return SafeArea(
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
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
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
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping,
                                      size: 80,
                                      color: AppColors.primaryBlue,
                                    ),
                                  );
                                },
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
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
                      child: Form(
                        key: _formKey,
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

                            // Username field
                            const Text(
                              'Nom d\'utilisateur',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              enabled: state is! AuthLoading,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.cardBackground,
                                hintText: 'Votre nom d\'utilisateur',
                                hintStyle: const TextStyle(
                                  color: AppColors.textGrey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: AppColors.primaryBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                errorStyle: const TextStyle(height: 0, fontSize: 0),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '';
                                }
                                return null;
                              },
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
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: state is! AuthLoading,
                              style: const TextStyle(
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.cardBackground,
                                hintText: '••••••••',
                                hintStyle: const TextStyle(
                                  color: AppColors.textGrey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.primaryBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                errorStyle: const TextStyle(height: 0, fontSize: 0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cardBackground,
                                  foregroundColor: AppColors.primaryBlue,
                                  disabledBackgroundColor:
                                      AppColors.cardBackground.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: state is AuthLoading
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      print('📱 Login Screen: Form validated, attempting login...');
      // Reset navigation flag
      _hasNavigated = false;
      // Hide keyboard
      FocusScope.of(context).unfocus();
      // Trigger login
      context.read<AuthCubit>().login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
    } else {
      // ✅ Show dialog for empty fields
      _showErrorDialog('Veuillez remplir tous les champs');
    }
  }

  /// Show error dialog with backend error message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getErrorColor(message).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(message),
                color: _getErrorColor(message),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Erreur de connexion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message, // ✅ Display backend error message directly
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            // Show solutions for connection errors
            if (_isConnectionError(message)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solutions possibles:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSolutionItem('Vérifiez que le serveur Django est démarré'),
                    _buildSolutionItem('Vérifiez l\'adresse IP dans l\'application'),
                    _buildSolutionItem('Vérifiez votre connexion WiFi'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isConnectionError(String message) {
    final connectionKeywords = [
      'serveur', 'connexion', 'network', 'timeout', 
      'internet', 'django', 'démarré'
    ];
    return connectionKeywords.any((keyword) => 
        message.toLowerCase().contains(keyword));
  }

  IconData _getErrorIcon(String message) {
    if (_isConnectionError(message)) {
      return Icons.cloud_off;
    } else if (message.contains('incorrect') || 
               message.contains('invalide') ||
               message.toLowerCase().contains('invalid')) {
      return Icons.lock_outline;
    } else if (message.contains('remplir') || 
               message.contains('champs')) {
      return Icons.edit_note;
    }
    return Icons.error_outline;
  }

  Color _getErrorColor(String message) {
    if (_isConnectionError(message)) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  Widget _buildSolutionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}