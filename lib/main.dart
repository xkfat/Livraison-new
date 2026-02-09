import 'package:deliverli/logic/cubit/commande/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_colors.dart';
import 'data/services/api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/commande_repository.dart';
import 'data/repositories/location_repository.dart';
import 'logic/cubit/auth/auth_cubit.dart';
import 'logic/cubit/auth/auth_state.dart';
import 'logic/cubit/commande/commande_cubit.dart';
import 'logic/cubit/tracking/tracking_cubit.dart';
import 'presentation/screens/driver/main_screen.dart';
import 'presentation/screens/splash/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService();
    final authRepository = AuthRepository(apiService);
    final commandeRepository = CommandeRepository(apiService);
    final locationRepository = LocationRepository(apiService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: commandeRepository),
        RepositoryProvider.value(value: locationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authRepository)..tryAutoLogin(),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(authRepository),
          ),
          BlocProvider(
            create: (context) => CommandeCubit(commandeRepository),
          ),
          BlocProvider(
            create: (context) => TrackingCubit(locationRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Deliverli',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primaryBlue,
            scaffoldBackgroundColor: AppColors.lightBackground,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              primary: AppColors.primaryBlue,
              secondary: AppColors.primaryDark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textGrey.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
            ),
          ),
          home: const AppNavigator(),
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        print('🔄 AppNavigator: Current state: ${state.runtimeType}');
        
        // ✅ Show splash while checking authentication (auto-login)
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        // ✅ ONLY navigate to MainScreen if AUTHENTICATED
        // This prevents navigation on AuthError
        if (state is AuthAuthenticated && state.user.isDriver) {
          print('✅ AppNavigator: Authenticated driver, showing MainScreen');
          return const MainScreen();
        }

        // ✅ If authenticated but not driver (admin, gestionnaire)
        if (state is AuthAuthenticated && !state.user.isDriver) {
          print('✅ AppNavigator: Authenticated non-driver: ${state.user.role}');
          // TODO: Add screens for admin/gestionnaire
          return const SplashScreen(); // Placeholder
        }

        // ✅ For UNAUTHENTICATED or ERROR states -> Show ForkScreen
        // This includes AuthUnauthenticated and AuthError
        // The login screen handles the error display via BlocListener
        print('📍 AppNavigator: Not authenticated, showing ForkScreen');
        return const ForkScreen();
      },
    );
  }
}

/// ✅ Force Logout Button Widget
class ForceLogoutButton extends StatelessWidget {
  const ForceLogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: TextButton(
          onPressed: () => _showForceLogoutDialog(context),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.refresh, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Forcer la déconnexion',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForceLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_outlined,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Forcer la déconnexion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Cela effacera toutes les données sauvegardées et vous déconnectera. Continuer ?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performForceLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Forcer la déconnexion'),
          ),
        ],
      ),
    );
  }

  Future<void> _performForceLogout(BuildContext context) async {
    try {
      print('🔄 Performing force logout...');
      
      // 1. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ SharedPreferences cleared');
      
      // 2. Logout via AuthCubit (clears API tokens)
      if (context.mounted) {
        await context.read<AuthCubit>().logout();
        print('✅ AuthCubit logout complete');
      }
      
      // 3. Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion forcée réussie'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      print('✅ Force logout complete');
      
    } catch (e) {
      print('❌ Error during force logout: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la déconnexion'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// ✅ Splash Screen with Force Logout Button
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          // Main splash content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    size: 80,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Deliverli',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          
          // ✅ Force logout button at the bottom
          const ForceLogoutButton(),
        ],
      ),
    );
  }
}