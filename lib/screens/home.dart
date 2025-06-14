import 'package:flutter/material.dart';
import 'package:huoo/screens/home_tab/home_tab.dart';
import 'package:huoo/screens/home_tab/library_tab.dart';
import 'package:huoo/screens/home_tab/search_tab.dart'; // Import the HomeTab widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // PageController to manage sliding between screens
  final PageController _pageController = PageController();

  // List of screens for each tab
  final List<Widget> _screens = [
    const HomeTab(),
    const SearchTab(),
    LibraryTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens, // Display the screens in a sliding manner
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor:
            theme.colorScheme.surface, // Set a solid background color
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Library'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController
        .dispose(); // Dispose the PageController when the widget is removed
    super.dispose();
  }
}
