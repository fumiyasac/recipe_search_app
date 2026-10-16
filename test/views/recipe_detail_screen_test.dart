import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/recipe_detail_screen.dart';

import '../support/network_image_mock.dart';

Recipe _sampleRecipe() => Recipe(
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
  ingredients: const ['スパゲッティ 200g', '卵黄 2個'],
  steps: [
    RecipeStep(stepNumber: 1, description: 'パスタを茹でる'),
    RecipeStep(stepNumber: 2, description: 'ソースを和える'),
  ],
  allergies: const ['卵', '乳製品'],
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
  cookingTools: const ['鍋', 'フライパン'],
);

void main() {
  testWidgets('レシピ詳細が主要情報を表示する', (tester) async {
    await provideMockNetworkImages(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(home: RecipeDetailScreen(recipe: _sampleRecipe())),
        ),
      );
      await tester.pumpAndSettle();

      // タイトルと栄養グラフが描画される
      expect(find.text('和風カルボナーラ'), findsWidgets);
      expect(find.text('栄養バランス'), findsOneWidget);
    });
  });
}
