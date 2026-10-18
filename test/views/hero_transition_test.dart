import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/calendar_screen.dart';
import 'package:recipe_search_app/views/main_navigation_screen.dart';
import 'package:recipe_search_app/views/recipe_detail_screen.dart';
import 'package:recipe_search_app/views/recipe_list_screen.dart';
import 'package:recipe_search_app/widgets/recipe_card.dart';

import '../support/network_image_mock.dart';

Recipe sampleRecipe({String id = '1'}) => Recipe(
  id: id,
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

(ProviderContainer, AppDatabase) makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
  return (container, db);
}

void main() {
  // A/B: 遷移先の Hero がテキスト（情報カード）を含んでいないこと。
  // 修正前は Hero が Stack(画像 + 情報カードのテキスト) を包むため失敗する。
  testWidgets('A/B: 詳細画面の Hero は画像だけを包み、テキストを含まない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: RecipeDetailScreen(recipe: sampleRecipe())),
        ),
      );
      await tester.pumpAndSettle();

      final hero = find.byType(Hero);
      expect(hero, findsOneWidget);
      // Hero のサブツリーに Text があってはいけない（遷移中に押しつぶし＋下線の原因）
      expect(
        find.descendant(of: hero, matching: find.byType(Text)),
        findsNothing,
        reason: 'Hero がテキスト（情報カード）を含んでいる（A/B の原因）',
      );
    });
  });

  // A/B/C/F: home → detail の遷移を途中で pump しても例外が出ないこと。
  testWidgets('home→detail の遷移を 0〜100% で pump しても例外が出ない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump(); // 遷移開始
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });
  });

  // D: カレンダー画面の遷移元に Hero があること（修正前は無いので失敗）。
  testWidgets('D: カレンダー画面のレシピに Hero がある', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CalendarScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Hero), findsWidgets, reason: 'カレンダーの遷移元に Hero が無い（D）');
    });
  });

  // F: 詳細を下にスクロール（SliverAppBar が縮む）してから戻っても例外が出ないこと。
  testWidgets('F: 詳細をスクロールしてから戻っても例外が出ない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);

      // 詳細を下にスクロールして SliverAppBar を縮める
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // 戻る（Hero 復路）
      final navigator = Navigator.of(
        tester.element(find.byType(CustomScrollView)),
      );
      navigator.pop();
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RecipeListScreen), findsOneWidget);
    });
  });

  // E: ホームとお気に入りの両タブに同じ tag の Hero が同時に存在し、遷移で tag が重複する。
  testWidgets('E: お気に入り登録済みレシピをホームから開くと Hero tag が重複しない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
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

      // ホーム先頭カードをお気に入り登録（→ お気に入りタブにも同じ Hero tag が出現）
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      // ホームのカード本体をタップして詳細へ遷移
      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // tag 重複の assertion（"multiple heroes ... same tag"）が出ないこと
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });
  });
}
