import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/main_navigation_screen.dart';
import 'package:recipe_search_app/views/recipe_detail_screen.dart';
import 'package:recipe_search_app/views/recipe_list_screen.dart';

import '../support/network_image_mock.dart';

Recipe _carbonara() => Recipe(
  id: '1',
  title: '和風カルボナーラ',
  description: '醤油と出汁が香る新感覚のカルボナーラ',
  imageUrl: 'https://example.com/image.jpg',
  category: '和食',
  prepTime: 10,
  cookTime: 15,
  servings: 2,
  calories: 520,
  rating: 4.8,
  ingredients: const ['スパゲッティ'],
  steps: [RecipeStep(stepNumber: 1, description: '茹でる')],
  allergies: const ['卵'],
  comments: const [],
  nutritionInfo: NutritionInfo(
    protein: 22.5,
    fat: 18.3,
    carbs: 65.2,
    fiber: 3.1,
    salt: 2.8,
  ),
  difficulty: 'medium',
  tags: const ['時短'],
  cookingTools: const ['鍋'],
);

(ProviderContainer, AppDatabase) _makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
  return (container, db);
}

void main() {
  testWidgets('一覧でハートを 2 回タップすると未登録に戻り、例外が出ない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = _makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      // 実アプリでは IndexedStack の FavoritesScreen が favoriteRecipesProvider を
      // 常時 listen して keepAlive 相当にしている。単体画面テストでも同様に保持する。
      container.listen(favoriteRecipesProvider, (prev, next) {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 1 回目: 先頭カードのハートで登録
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();
      expect(await db.getAllFavorites(), isNotEmpty);

      // 2 回目: 同じカードのハート（登録済み）をタップ → 解除されるべき
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle();

      expect(await db.getAllFavorites(), isEmpty);
    });
  });

  testWidgets('詳細画面で登録・解除を 2 往復できる', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = _makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      // 実アプリでは FavoritesScreen が常時 listen して保持している状態を再現。
      container.listen(favoriteRecipesProvider, (prev, next) {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: RecipeDetailScreen(recipe: _carbonara())),
        ),
      );
      await tester.pumpAndSettle();

      for (var round = 0; round < 2; round++) {
        // 登録
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();
        expect(await db.isFavorite('1'), isTrue, reason: 'round $round 登録');

        // 解除
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();
        expect(await db.isFavorite('1'), isFalse, reason: 'round $round 解除');
      }
    });
  });

  testWidgets('一覧で登録したものがお気に入りタブに表示され、解除すると消える', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = _makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainNavigationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // ホームタブで先頭カードを登録
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      // お気に入りタブに切り替え → 表示される
      await tester.tap(find.text('お気に入り'));
      await tester.pumpAndSettle();
      expect(find.text('和風カルボナーラ'), findsOneWidget);

      // ホームに戻って解除（ホームタブでは nav の favorite は非アクティブ=favorite_outline
      // なので、Icons.favorite はカードの塗りつぶしハートのみ）
      await tester.tap(find.text('ホーム'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle();

      // お気に入りタブから消える
      await tester.tap(find.text('お気に入り'));
      await tester.pumpAndSettle();
      expect(find.text('和風カルボナーラ'), findsNothing);
    });
  });
}
