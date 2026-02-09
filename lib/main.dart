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
import 'presentation/screens/splash/welcome_screen.dart'; // Assurez-vous que ForkScreen est défini ici ou importé

void main() async {
  // Nécessaire pour initialiser les services avant l'app si besoin
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialisation des instances (Singletons de fait via le Provider)
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
          ),
          home: const AppNavigator(),
        ),
      ),
    );
  }
}

// Dans ton fichier main.dart, modifie la classe AppNavigator

class AppNavigator extends StatelessWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is AuthAuthenticated) {
          // ⚡ ÉTAPE 1 : SYNCHRONISATION SYNCHRONE
          final apiService = RepositoryProvider.of<ApiService>(context);
          apiService.setTokens(state.accessToken, state.refreshToken);

          if (state.user.isDriver) {
            // ⚡ ÉTAPE 2 : On ne rend le MainScreen QUE SI le token est prêt
            print('✅ AppNavigator: Token injecté, chargement du MainScreen');
            return const MainScreen();
          }
          return const ForkScreen();
        }

        return const ForkScreen();
      },
    );
  }
}
// --- Les composants utilitaires ci-dessous restent identiques à votre version ---

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
              Text('Forcer la déconnexion', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
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
        title: const Text('Forcer la déconnexion'),
        content: const Text('Cela effacera les données et vous déconnectera. Continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) await context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_shipping, size: 80, color: Colors.white),
                SizedBox(height: 32),
                Text('Deliverli', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 48),
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ],
            ),
          ),
          const ForceLogoutButton(),
        ],
      ),
    );
  }
}