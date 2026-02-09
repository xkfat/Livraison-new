import 'package:flutter/material.dart';
import 'tracking_details_screen.dart';
import '../../../core/constants/app_colors.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final TextEditingController _controller = TextEditingController();

  void _searchOrder() {
    if (_controller.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingDetailsScreen(trackingId: _controller.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez entrer le numéro de colis'),
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
            color: AppColors.primaryBlue
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          hintText: "Ex: TRK-123",
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search Button - adapts size
                      SizedBox(
                        width: double.infinity,
                        height: keyboardVisible ? 44 : 52,
                        child: ElevatedButton(
                          onPressed: _searchOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            foregroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
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
}