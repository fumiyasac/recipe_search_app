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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
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
                          top: Radius.circular(16),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(recipe.imageUrl),
                          fit: BoxFit.cover,
                        ),
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isFavoriteAsync.when(
                              data: (isFavorite) => Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF6A6A6A),
                                size: 20,
                              ),
                              loading: () => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                ),
                              ),
                              error: (error, stack) => Icon(
                                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: recipe.isFavorite
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF6A6A6A),
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
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 説明文
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A6A6A),
                        height: 1.4,
                        letterSpacing: 0,
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
                          Icons.schedule_outlined,
                          size: 15,
                          color: const Color(0xFF6A6A6A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalTime}分',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 評価
                        Icon(
                          Icons.star,
                          size: 15,
                          color: const Color(0xFFF7931E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // カロリー
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${recipe.calories}kcal',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4A4A4A),
                              fontWeight: FontWeight.w600,
                            ),
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
