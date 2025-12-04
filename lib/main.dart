import 'package:diagonal/screens/homescreen.dart';
import 'package:diagonal/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  print("yaha tak chal gaya");
  await AdService.instance.initialize();
  print('yaha pe error nahi hai');
  // await MobileAds.instance.initialize();
  runApp(const DiagonalApp());
}

class DiagonalApp extends StatelessWidget {
  const DiagonalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagonal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A1E3D),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A1E3D),
          primary: const Color(0xFF0A1E3D),
          secondary: const Color(0xFF1E3A5F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1E3D),
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A1E3D),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const MaintenanceChecker(),
    );
  }
}

class MaintenanceChecker extends StatelessWidget {
  const MaintenanceChecker({super.key});

  bool isMaintenanceTime() {
    final now = DateTime.now();
    final hour = now.hour;
    // Check if time is between 12 AM (0) and 10 AM (9)
    return hour >= 0 && hour < 10;
  }

  @override
  Widget build(BuildContext context) {
    if (isMaintenanceTime()) {
      return const MaintenanceScreen();
    }
    return const HomeScreen();
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1E3D),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 100,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 40),
                Text(
                  'Server Maintenance',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Our servers are down for maintenance\nfrom 12:00 AM to 10:00 AM',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Please try again after 10:00 AM',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Icon(
                  Icons.schedule,
                  size: 40,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}