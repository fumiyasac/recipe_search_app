import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recipe.dart';
import '../viewmodels/providers.dart';
import '../widgets/nutrition_chart.dart';

class RecipeDetailScreen extends HookConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero画像とAppBar
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Consumer(
                builder: (context, watch, child) {
                  final isFavoriteAsync = ref.watch(
                    recipeFavoriteStatusProvider(recipe.id),
                  );
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
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
                        data: (isFavorite) => IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF1A1A1A),
                          ),
                          onPressed: () async {
                            await ref
                                .read(favoriteRecipesProvider.notifier)
                                .toggleFavorite(recipe);
                            ref.invalidate(recipeListProvider);
                          },
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                        ),
                        error: (error, stack) => IconButton(
                          icon: Icon(
                            recipe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: recipe.isFavorite
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF1A1A1A),
                          ),
                          onPressed: () async {
                            await ref
                                .read(favoriteRecipesProvider.notifier)
                                .toggleFavorite(recipe);
                            ref.invalidate(recipeListProvider);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe-${recipe.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(recipe.imageUrl, fit: BoxFit.cover),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                recipe.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              recipe.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // コンテンツ
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メタ情報
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        _buildInfoCard(
                          Icons.schedule,
                          '${recipe.totalTime}分',
                          '調理時間',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          Icons.restaurant,
                          '${recipe.servings}人分',
                          '分量',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          Icons.local_fire_department,
                          '${recipe.calories}',
                          'kcal',
                        ),
                      ],
                    ),
                  ),
                  // 説明
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      recipe.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFF4A4A4A),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 難易度と評価
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // 難易度
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              recipe.difficulty,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getDifficultyColor(recipe.difficulty),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getDifficultyIcon(recipe.difficulty),
                                color: _getDifficultyColor(recipe.difficulty),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getDifficultyLabel(recipe.difficulty),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getDifficultyColor(recipe.difficulty),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 評価
                        Icon(
                          Icons.star,
                          color: const Color(0xFFF7931E),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${recipe.rating}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${recipe.comments.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 栄養情報
                  if (recipe.nutritionInfo != null) ...[
                    _buildSectionTitle('栄養成分（1人分）'),
                    // グラフ表示
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: NutritionChart(
                        nutritionInfo: recipe.nutritionInfo!,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // アレルギー情報
                  if (recipe.allergies.isNotEmpty) ...[
                    _buildSectionTitle('アレルギー情報'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recipe.allergies
                            .map(
                              (allergy) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  allergy,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF6B35),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // タグ
                  if (recipe.tags.isNotEmpty) ...[
                    _buildSectionTitle('タグ'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recipe.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF4CAF50),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getTagIcon(tag),
                                      size: 14,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // 調理器具
                  if (recipe.cookingTools.isNotEmpty) ...[
                    _buildSectionTitle('必要な調理器具'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: recipe.cookingTools
                              .map(
                                (tool) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCookingToolIcon(tool),
                                        size: 18,
                                        color: const Color(0xFFFF6B35),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        tool,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // 材料
                  _buildSectionTitle('材料'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: recipe.ingredients
                            .map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF6B35),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 作り方
                  _buildSectionTitle('作り方'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: recipe.steps.map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  shape: BoxShape.circle,
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
                                child: Center(
                                  child: Text(
                                    '${step.stepNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    step.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.7,
                                      color: Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // コメント
                  if (recipe.comments.isNotEmpty) ...[
                    _buildSectionTitle('レビュー'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: recipe.comments.map((comment) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        comment.userAvatar,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.userName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                index < comment.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 14,
                                                color: const Color(0xFFF7931E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  comment.comment,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: Color(0xFF4A4A4A),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF6B35), size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6A6A6A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'hard':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFFF7931E);
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'hard':
        return Icons.whatshot;
      default:
        return Icons.thumb_up;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '簡単';
      case 'hard':
        return '上級';
      default:
        return '中級';
    }
  }

  IconData _getTagIcon(String tag) {
    final lowerTag = tag.toLowerCase();
    if (lowerTag.contains('ベジタリアン') || lowerTag.contains('野菜')) {
      return Icons.spa;
    } else if (lowerTag.contains('時短') || lowerTag.contains('簡単')) {
      return Icons.timer;
    } else if (lowerTag.contains('ヘルシー') || lowerTag.contains('低カロリー')) {
      return Icons.favorite;
    } else if (lowerTag.contains('作り置き')) {
      return Icons.calendar_today;
    } else if (lowerTag.contains('グルテンフリー')) {
      return Icons.no_meals;
    } else {
      return Icons.label;
    }
  }

  IconData _getCookingToolIcon(String tool) {
    final lowerTool = tool.toLowerCase();
    if (lowerTool.contains('フライパン')) {
      return Icons.set_meal;
    } else if (lowerTool.contains('鍋') || lowerTool.contains('ポット')) {
      return Icons.soup_kitchen;
    } else if (lowerTool.contains('オーブン')) {
      return Icons.microwave;
    } else if (lowerTool.contains('ボウル')) {
      return Icons.rice_bowl;
    } else if (lowerTool.contains('包丁') || lowerTool.contains('ナイフ')) {
      return Icons.restaurant_menu;
    } else if (lowerTool.contains('まな板')) {
      return Icons.countertops;
    } else if (lowerTool.contains('ミキサー') || lowerTool.contains('ブレンダー')) {
      return Icons.blender;
    } else {
      return Icons.kitchen;
    }
  }
}
