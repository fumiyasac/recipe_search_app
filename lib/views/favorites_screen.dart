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
              color: Color(0xFFFF6B35),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'お気に入り',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ],
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
                    color: const Color(0xFF6A6A6A).withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'お気に入りのレシピがありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ハートマークをタップしてお気に入りに追加',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w500,
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: const Color(0xFF6A6A6A).withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'エラーが発生しました',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6A6A6A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
