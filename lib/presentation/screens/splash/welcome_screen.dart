import 'package:flutter/material.dart';
import '../client/tracking_details_screen.dart'; 
import '../driver/login_screen.dart';
import '../client/client_login_screen.dart';

class ForkScreen extends StatelessWidget {
  const ForkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO IMAGE (Replaced Text/Icon)
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // YOUR LOGO HERE
                      Image.asset(
                        'assets/images/Logo.png',
                        width: 500, 
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      
                    ],
                  ),
                ),
              ),

              // 2. BUTTONS
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text("Qui êtes-vous ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    
                    // BUTTON A: CLIENT (Green)
                    _buildBigButton(
                      context,
                      title: "SUIVRE UN COLIS",
                      subtitle: "Accès Client (Sans compte)",
                      icon: Icons.search,
                      color: Color(0xFF10B981),
                      onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (_) => ClientLoginScreen()));                      },
                    ),
                    
                    SizedBox(height: 16),

                    // BUTTON B: DRIVER (Blue)
                    _buildBigButton(
                      context,
                      title: "ESPACE LIVREUR",
                      subtitle: "Connexion Requise",
                      icon: Icons.motorcycle,
                      color: Color(0xFF2563EB), // Blue
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}