import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recipe.dart';
import '../viewmodels/providers.dart';
import '../views/recipe_detail_screen.dart';

class RecipeCard extends HookConsumerWidget {
  final Recipe recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画像部分
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Hero Animation用の画像
                  Hero(
                    tag: 'recipe-${recipe.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(recipe.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // グラデーションオーバーレイ
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // お気に入りボタン
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Consumer(
                      builder: (context, watch, child) {
                        final isFavoriteAsync = ref.watch(recipeFavoriteStatusProvider(recipe.id));
                        return GestureDetector(
                          onTap: () async {
                            await ref
                                .read(favoriteRecipesProvider.notifier)
                                .toggleFavorite(recipe);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: isFavoriteAsync.when(
                              data: (isFavorite) => Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFFFF6B6B)
                                    : const Color(0xFF8D6E63),
                                size: 20,
                              ),
                              loading: () => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6E63)),
                                ),
                              ),
                              error: (error, stack) => Icon(
                                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: recipe.isFavorite
                                    ? const Color(0xFFFF6B6B)
                                    : const Color(0xFF8D6E63),
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // カテゴリタグ
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9E80).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // テキスト情報部分
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // タイトル
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41),
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 説明文
                    Text(
                      recipe.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF8D6E63).withOpacity(0.8),
                        fontFamily: 'Poppins',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // メタ情報
                    Row(
                      children: [
                        // 調理時間
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: const Color(0xFFFF9E80).withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalTime}分',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8D6E63),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 評価
                        Icon(
                          Icons.star,
                          size: 14,
                          color: const Color(0xFFFFB74D).withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8D6E63),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        // カロリー
                        Text(
                          '${recipe.calories}kcal',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF8D6E63).withOpacity(0.7),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
