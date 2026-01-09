import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'views/recipe_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ステータスバーのスタイルを設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 薄いオレンジを基調とした配色
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9E80),
          primary: const Color(0xFFFF9E80),
          secondary: const Color(0xFFFFB74D),
          surface: const Color(0xFFFFF8F5),
          background: const Color(0xFFFFFAF5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFAF5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFFFFFAF5),
          foregroundColor: Color(0xFF6D4C41),
          titleTextStyle: TextStyle(
            fontFamily: 'Playfair',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            letterSpacing: 0.5,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Playfair',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
          displayMedium: TextStyle(
            fontFamily: 'Playfair',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF8D6E63),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF8D6E63),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const RecipeListScreen(),
    );
  }
}
