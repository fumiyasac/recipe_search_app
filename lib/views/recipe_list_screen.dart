import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_hero_image.dart';
import '../widgets/filter_section.dart';

class RecipeListScreen extends HookConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFFFF6B35), size: 28),
            SizedBox(width: 12),
            Text(
              'レシピ検索',
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
      body: CustomScrollView(
        slivers: [
          // フィルターセクション
          const SliverToBoxAdapter(child: FilterSection()),
          // レシピグリッド
          recipesAsync.when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: const Color(0xFF6A6A6A).withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'レシピが見つかりませんでした',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return RecipeCard(
                      recipe: recipes[index],
                      heroSource: HeroSource.home,
                    );
                  }, childCount: recipes.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              ),
            ),
            error: (error, stack) => const SliverFillRemaining(
              child: Center(
                child: Text(
                  'エラーが発生しました',
                  style: TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // 下部のパディング
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
