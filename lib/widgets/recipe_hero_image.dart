import 'package:flutter/material.dart';

/// 遷移元の種類。Hero タグに含めて、同一ルート上でのタグ重複（IndexedStack の
/// ホーム/お気に入り両タブに同じ id が同時存在する等）を防ぐ。
enum HeroSource { home, favorites, calendar }

/// Hero タグを文字列直書きせずに生成するヘルパー。
class RecipeHeroTag {
  const RecipeHeroTag._();

  /// レシピ画像の Hero タグ。遷移元（[source]）ごとに一意になる。
  /// 同一画面に同じレシピが複数並ぶ場合（カレンダーの「選択日」カードと一覧など）は
  /// [key] で区別する。これを付けないと同一ルート上でタグが重複する。
  static String image(String recipeId, HeroSource source, {String? key}) =>
      'recipe-image-${source.name}-${key == null ? '' : '$key-'}$recipeId';
}

/// 遷移元と遷移先で共通して使う、画像専用の Hero ウィジェット。
///
/// - Hero で包むのは画像だけ（テキストや情報カードは含めない）。
/// - 角丸は [borderRadius] で受け取り、`flightShuttleBuilder` で遷移中に補間する。
/// - 遷移元/先で同じ [ImageProvider]（`NetworkImage(imageUrl)`）を使い、
///   遷移中に画像が一瞬消えないようにする。
/// - 読み込み中は [placeholder]、失敗時は error 表示を出す。
/// - 端末の「視差効果を減らす」設定（`MediaQuery.disableAnimations`）が ON、
///   または [heroEnabled] が false のときは Hero を無効化する。
class RecipeHeroImage extends StatelessWidget {
  final String recipeId;
  final String imageUrl;
  final HeroSource source;

  /// 同一画面でタグが重複しないようにするための識別子（任意）。
  final String? tagKey;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// false にすると Hero を無効化する（例: 詳細の AppBar が縮んだ状態）。
  final bool heroEnabled;

  const RecipeHeroImage({
    super.key,
    required this.recipeId,
    required this.imageUrl,
    required this.source,
    this.tagKey,
    this.borderRadius = BorderRadius.zero,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.heroEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 遷移元/先で同一の ImageProvider（キャッシュキーが一致し、遷移中に再読込しない）
    final provider = NetworkImage(imageUrl);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return HeroMode(
      enabled: heroEnabled && !reduceMotion,
      child: Hero(
        tag: RecipeHeroTag.image(recipeId, source, key: tagKey),
        flightShuttleBuilder:
            (flightContext, animation, direction, fromContext, toContext) {
              final fromRadius = _radiusOf(fromContext);
              final toRadius = _radiusOf(toContext);
              // 遷移中の描画はテキスト下線等を避けるため Material(transparency) で包む
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final radius =
                      BorderRadius.lerp(
                        fromRadius,
                        toRadius,
                        animation.value,
                      ) ??
                      BorderRadius.zero;
                  return Material(
                    type: MaterialType.transparency,
                    child: _buildImage(provider, radius),
                  );
                },
              );
            },
        child: _buildImage(provider, borderRadius),
      ),
    );
  }

  Widget _buildImage(ImageProvider provider, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Image(
        image: provider,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _placeholder();
        },
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      ),
    );
  }

  // 読み込み中の静的プレースホルダ。アニメーション（スピナー）は使わない
  // （無限アニメーションだと pumpAndSettle が収束しない／UX 上も明滅しにくい）。
  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(Icons.restaurant_menu, color: Color(0xFFD0D0D0), size: 28),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEDEDED),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Color(0xFF9A9A9A),
          size: 32,
        ),
      ),
    );
  }

  // flightShuttleBuilder の from/to コンテキストから角丸を取り出す。
  static BorderRadius _radiusOf(BuildContext heroContext) {
    final widget = heroContext.widget;
    if (widget is Hero && widget.child is RecipeHeroImage) {
      return (widget.child as RecipeHeroImage).borderRadius;
    }
    return BorderRadius.zero;
  }
}
