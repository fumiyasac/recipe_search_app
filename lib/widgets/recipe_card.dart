import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recipe.dart';
import '../viewmodels/providers.dart';
import '../views/recipe_detail_screen.dart';

class RecipeCard extends HookConsumerWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  // お気に入りの切替。判定は DB の現在状態（toggleFavorite 内）で行い、
  // ここでは保存に必要な recipe を渡すだけ。処理中は二重実行を防ぎ、失敗は SnackBar で通知。
  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> busy,
  ) async {
    if (busy.value) return;
    busy.value = true;
    try {
      await ref.read(recipeRepositoryProvider).toggleFavorite(recipe);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('お気に入りの更新に失敗しました')));
      }
    } finally {
      if (context.mounted) busy.value = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // お気に入り状態は favoriteIds から導出した recipeFavoriteStatusProvider だけを見る。
    final isFavorite = ref.watch(recipeFavoriteStatusProvider(recipe.id));
    final isToggling = useState(false);

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
                  // お気に入りボタン（recipeFavoriteStatusProvider から導出）
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(context, ref, isToggling),
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
                        child: isToggling.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6B35),
                                  ),
                                ),
                              )
                            : Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF6A6A6A),
                                size: 20,
                              ),
                      ),
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
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.3),
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // タイトル
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 説明文
                          Text(
                            recipe.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6A6A6A),
                              height: 1.3,
                              letterSpacing: 0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // メタ情報
                    Row(
                      children: [
                        // 調理時間
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: Color(0xFF6A6A6A),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.totalTime}分',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 評価
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFF7931E),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
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
