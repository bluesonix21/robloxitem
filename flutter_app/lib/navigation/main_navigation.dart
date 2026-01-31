import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/my_designs/my_designs_screen.dart';
import '../features/create/create_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/discover/discover_screen.dart';
import '../shared/widgets/app_shell.dart';

/// Main Navigation Screen with Bottom Navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyDesignsScreen(),
    CreateScreen(),
    TemplatesScreen(),
    DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MainAppShell(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
