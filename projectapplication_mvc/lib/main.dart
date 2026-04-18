import 'package:flutter/material.dart';
import 'package:projectapplication/views/screens/cart_screen.dart';
import 'package:projectapplication/views/screens/home_screen.dart';
import 'package:projectapplication/views/screens/login_screen.dart';
import 'package:projectapplication/views/screens/profile_screen.dart';
import 'package:projectapplication/views/screens/search_screen.dart';
import 'package:projectapplication/views/screens/wishlist_screen.dart';
import 'package:projectapplication/views/widgets/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URBNOVA',
      debugShowCheckedModeBanner: false,
      // App starts at the login screen
      home: const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    WishlistScreen(),
    ProfileScreen(),
    CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
