import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onBookNowPressed: () => _navigateToTab(1),
        onViewMyBookings: () => _navigateToTab(2),
      ),
      BookingScreen(
        onNavigateToHistory: () => _navigateToTab(2),
      ),
      MyBookingsScreen(
        onBookNewPressed: () => _navigateToTab(1),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
      ),
    );
  }
}
