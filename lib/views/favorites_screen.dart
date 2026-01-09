import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/providers.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends HookConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.favorite,
              color: Color(0xFFFF6B6B),
              size: 28,
            ),
            SizedBox(width: 12),
            Text('お気に入り'),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9E80).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6D4C41),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: const Color(0xFF8D6E63).withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'お気に入りのレシピがありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF8D6E63).withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ハートマークをタップしてお気に入りに追加',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8D6E63).withOpacity(0.5),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return RecipeCard(recipe: favorites[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E80)),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: const Color(0xFF8D6E63).withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF8D6E63).withOpacity(0.7),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
