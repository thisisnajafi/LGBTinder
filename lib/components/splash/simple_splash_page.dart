import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../components/navbar/lgbtinder_logo.dart';

/// Simple, robust splash page with minimal complexity
class SimpleSplashPage extends StatefulWidget {
  const SimpleSplashPage({super.key});

  @override
  State<SimpleSplashPage> createState() => _SimpleSplashPageState();
}

class _SimpleSplashPageState extends State<SimpleSplashPage> {
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Minimum splash time for better UX
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Trigger the actual app initialization
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.initializeApp();
      }
    } catch (e) {
      print('Splash initialization error: $e');
      // Complete with error state
      if (mounted) {
        try {
          final appState = Provider.of<AppStateProvider>(context, listen: false);
          appState.setLoading(false);
          appState.setUserState(null); // Set null to go to welcome screen
        } catch (contextError) {
          print('Context error: $contextError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.gray800,
              AppColors.secondary,
              AppColors.accent,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 3),
              // Simple logo without animations
              LGBTinderLogo(size: 120),
              
              Spacer(flex: 2),
              
              // Simple loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              
              SizedBox(height: 24),
              
              Text(
                'Welcome to LGBTinder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Connecting hearts across the rainbow',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              
              Spacer(flex: 1),
              
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  'LGBTinder by PrideTech',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
