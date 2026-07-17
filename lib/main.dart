import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/app_provider.dart';
import 'providers/menu_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/editor/editor_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/family/family_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FamilyRecipeApp());
}

class FamilyRecipeApp extends StatelessWidget {
  const FamilyRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.light,
        home: const MainScreen(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        primary: AppConstants.primaryColor,
        primaryContainer: AppConstants.primaryContainer,
        onPrimary: AppConstants.onPrimary,
        secondary: AppConstants.secondaryColor,
        secondaryContainer: AppConstants.secondaryContainer,
        background: AppConstants.backgroundColor,
        surface: AppConstants.cardColor,
        error: AppConstants.errorColor,
        errorContainer: AppConstants.errorContainer,
        outline: AppConstants.outlineColor,
        surfaceVariant: AppConstants.surfaceVariant,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        color: AppConstants.cardColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppConstants.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.cardColor,
        indicatorColor: AppConstants.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            color: AppConstants.primaryColor,
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(color: AppConstants.primaryColor),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // 字体主题
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          color: AppConstants.textPrimary,
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.w500,
          color: AppConstants.primaryColor,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(color: AppConstants.outlineColor),
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: AppConstants.outlineColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/detail':
        final args = settings.arguments as Map<String, dynamic>??;
        final recipeId = args?['recipeId'] as String?;
        return MaterialPageRoute(
          builder: (context) => DetailScreen(recipeId: recipeId),
          settings: settings,
        );

      case '/editor':
        final args = settings.arguments as Map<String, dynamic>??;
        final recipeId = args?['recipeId'] as String?;
        return MaterialPageRoute(
          builder: (context) => EditorScreen(recipeId: recipeId),
          settings: settings,
        );

      case '/favorites':
        return MaterialPageRoute(
          builder: (context) => const FavoritesScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}

/// 主屏幕 - 包含底部导航栏和四个主要页面
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MenuScreen(),
    const FamilyScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final recipeProvider = context.read<RecipeProvider>();
    final appProvider = context.read<AppProvider>();
    final menuProvider = context.read<MenuProvider>();

    await Future.wait([
      recipeProvider.initialize(),
      appProvider.initialize(),
      menuProvider.initialize(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: AppConstants.tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.title,
            selectedIcon: Icon(tab.icon),
          );
        }).toList(),
      ),
    );
  }
}