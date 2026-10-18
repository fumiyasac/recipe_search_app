import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recipe.dart';
import '../viewmodels/providers.dart';
import '../widgets/nutrition_chart.dart';
import '../widgets/recipe_hero_image.dart';

class RecipeDetailScreen extends HookConsumerWidget {
  final Recipe recipe;
  final HeroSource heroSource;

  /// 遷移元の Hero タグ識別子（カレンダーの選択日カード/一覧の区別など）。
  final String? heroTagKey;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.heroSource = HeroSource.home,
    this.heroTagKey,
  });

  /// 詳細画面への遷移を 1 箇所にまとめるヘルパー。
  /// 「視差効果を減らす」設定が ON のときは遷移を無しにする（Hero も HeroMode で無効化）。
  static Route<void> route(
    BuildContext context,
    Recipe recipe,
    HeroSource source, {
    String? tagKey,
  }) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final page = RecipeDetailScreen(
      recipe: recipe,
      heroSource: source,
      heroTagKey: tagKey,
    );
    if (reduceMotion) {
      return PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => page,
      );
    }
    return MaterialPageRoute<void>(builder: (_) => page);
  }

  // お気に入りの切替。判定は DB の現在状態で行い、処理中は二重実行を防ぎ、
  // 失敗は SnackBar で通知する。
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
    final isFavorite = ref.watch(recipeFavoriteStatusProvider(recipe.id));
    final isToggling = useState(false);

    // F 対応: SliverAppBar が縮んだら Hero を無効化し、戻りの遷移を自然にする。
    final scrollController = useScrollController();
    final collapsed = useState(false);
    useEffect(() {
      void listener() {
        final isCollapsed =
            scrollController.hasClients && scrollController.offset > 250;
        if (isCollapsed != collapsed.value) collapsed.value = isCollapsed;
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
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
              Padding(
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
                  child: isToggling.value
                      ? const Padding(
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
                        )
                      : IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF1A1A1A),
                          ),
                          onPressed: () =>
                              _toggleFavorite(context, ref, isToggling),
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero で包むのは画像だけ（情報カードは含めない）
                  RecipeHeroImage(
                    recipeId: recipe.id,
                    imageUrl: recipe.imageUrl,
                    source: heroSource,
                    tagKey: heroTagKey,
                    heroEnabled: !collapsed.value,
                  ),
                  // 情報カードは Hero の外。遷移の後半でフェード＋スライド表示する。
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _InfoCard(
                      category: recipe.category,
                      title: recipe.title,
                    ),
                  ),
                ],
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

/// 詳細画面のタイトル情報カード。Hero の外に置き、ルートの遷移アニメーションに
/// 合わせて後半でフェード＋スライドイン（戻りはフェードアウト）する。
class _InfoCard extends StatelessWidget {
  final String category;
  final String title;

  const _InfoCard({required this.category, required this.title});

  @override
  Widget build(BuildContext context) {
    final animation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // 遷移の後半（0.4〜1.0）でフェード＋少し上へスライド
        final t = const Interval(
          0.4,
          1.0,
          curve: Curves.easeOut,
        ).transform(animation.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: child,
          ),
        );
      },
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
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
              title,
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
    );
  }
}
