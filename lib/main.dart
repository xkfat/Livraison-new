import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'data/services/api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/commande_repository.dart';
import 'data/repositories/location_repository.dart';
import 'logic/cubit/auth/auth_cubit.dart';
import 'logic/cubit/auth/auth_state.dart';
import 'logic/cubit/commande/commande_cubit.dart';
import 'logic/cubit/tracking/tracking_cubit.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/client/tracking_details_screen.dart';
import 'presentation/screens/driver/driver_home_screen.dart';
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
            create: (context) => CommandeCubit(commandeRepository),
          ),
          BlocProvider(
            create: (context) => TrackingCubit(locationRepository),
          ),
        ],
        child: MaterialApp(
          title: 'DeliveryPro',
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
        // Show splash screen while checking authentication
   if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        // If a DRIVER is already logged in, go straight to their home
        if (state is AuthAuthenticated && state.user.isDriver) {
          return const DriverHomeScreen();
        }

        // FOR EVERYONE ELSE (Clients, Unauthenticated, Logged out):
        // Show the Fork Screen (Choice between Client & Driver)
        return const ForkScreen(); 
      },

       

    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
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
              'DeliveryPro',
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
    );
  }
}