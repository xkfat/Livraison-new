import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tracking_details_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/tracking/tracking_cubit.dart';
import '../../../logic/cubit/tracking/tracking_state.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  void _searchOrder() async {
    final trackingId = _controller.text.trim();
    
    if (trackingId.isEmpty) {
      _showErrorSnackbar('Veuillez entrer le numéro de colis');
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Verify tracking exists before navigating
    final cubit = context.read<TrackingCubit>();
    await cubit.trackCommande(trackingId);

    if (!mounted) return;

    final state = cubit.state;
    
    setState(() {
      _isSearching = false;
    });

    if (state is TrackingLoaded) {
      // Success - navigate to details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingDetailsScreen(trackingId: trackingId),
        ),
      );
    } else if (state is TrackingNotFound) {
      // Show error dialog
      _showErrorDialog(
        title: 'Colis introuvable',
        message: 'Le numéro de suivi "$trackingId" n\'existe pas.\nVeuillez vérifier et réessayer.',
      );
    } else if (state is TrackingError) {
      // Show error dialog with backend message
      _showErrorDialog(
        title: 'Erreur',
        message: state.message,
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.textLight, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION - Logo area (shrinks when keyboard appears)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: keyboardVisible 
                  ? MediaQuery.of(context).size.height * 0.15 
                  : MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    top: 10,
                    left: 10,
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
                  // Logo - centered
                  Center(
                    child: AnimatedOpacity(
                      opacity: keyboardVisible ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Logo.png',
                            height: keyboardVisible ? 0 : 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Espace Client',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Suivre un colis",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Entrez le numéro de commande pour accéder au suivi.",
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input Field
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppColors.textDark),
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _searchOrder(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          hintText: "Ex: TRK-123",
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          prefixIcon: Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primaryBlue.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search Button - adapts size and shows loading
                      SizedBox(
                        width: double.infinity,
                        height: keyboardVisible ? 44 : 52,
                        child: ElevatedButton(
                          onPressed: _isSearching ? null : _searchOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            foregroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: AppColors.cardBackground.withOpacity(0.6),
                            disabledForegroundColor: AppColors.primaryBlue.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSearching
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryBlue,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Accéder au suivi",
                                  style: TextStyle(
                                    fontSize: keyboardVisible ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}