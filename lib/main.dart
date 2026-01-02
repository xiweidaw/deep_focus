import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/storage/storage_service.dart';
import 'features/home/screens/home_screen.dart';
// 引入新的 JournalScreen
import 'features/journal/screens/journal_screen.dart'; 
import 'features/settings/screens/me_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const EfficiencyApp(),
    ),
  );
}

class EfficiencyApp extends StatelessWidget {
  const EfficiencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'DeepFocus',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const JournalScreen(), // 替换了原来的 TimelineScreen
    const MeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? Colors.grey[800] : Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            // Home
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined), 
              activeIcon: Icon(Icons.circle), 
              label: 'Focus'
            ),
            // Journal (新图标：书本)
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), 
              activeIcon: Icon(Icons.book), 
              label: 'Journal'
            ),
            // Me
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person), 
              label: 'Me'
            ),
          ],
        ),
      ),
    );
  }
}
