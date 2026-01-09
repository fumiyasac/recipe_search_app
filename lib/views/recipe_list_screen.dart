import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../viewmodels/providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/filter_section.dart';
import 'favorites_screen.dart';
import 'calendar_screen.dart';

class RecipeListScreen extends HookConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final recipesAsync = ref.watch(
      filteredRecipesProvider(selectedCategory, searchQuery),
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // カスタムAppBar
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFFFFFAF5),
              elevation: 0,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Row(
                  children: [
                    const Text(
                      'Recipe',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9E80).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6F40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // お気に入りボタン
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9E80).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFFF6B6B),
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                // カレンダーボタン
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFFF9E80),
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            // フィルターセクション
            const SliverToBoxAdapter(
              child: FilterSection(),
            ),
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
                            color: const Color(0xFF8D6E63).withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'レシピが見つかりませんでした',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF8D6E63).withOpacity(0.7),
                              fontFamily: 'Poppins',
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RecipeCard(recipe: recipes[index]);
                      },
                      childCount: recipes.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E80)),
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'エラーが発生しました',
                    style: TextStyle(
                      color: const Color(0xFF8D6E63).withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            // 下部のパディング
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}
