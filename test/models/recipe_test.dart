import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/models/recipe.dart';

Recipe buildRecipe() {
  return Recipe(
    id: '1',
    title: 'テストレシピ',
    description: '説明',
    imageUrl: 'https://example.com/image.jpg',
    category: '和食',
    prepTime: 10,
    cookTime: 15,
    servings: 2,
    calories: 400,
    rating: 4.5,
    ingredients: const ['材料A', '材料B'],
    steps: [RecipeStep(stepNumber: 1, description: '手順1')],
    allergies: const ['卵'],
    comments: const [],
  );
}

void main() {
  group('Recipe.totalTime', () {
    test('prepTime と cookTime の合計を返す', () {
      final recipe = buildRecipe();
      expect(recipe.totalTime, 25);
    });
  });

  group('Recipe.copyWith', () {
    test('一部フィールドのみ変更し、他フィールドは保持する', () {
      final recipe = buildRecipe();
      final updated = recipe.copyWith(title: '新タイトル');

      expect(updated.title, '新タイトル');
      expect(updated.id, recipe.id);
      expect(updated.totalTime, recipe.totalTime);
    });

    test('指定しなければ元の値を維持する', () {
      final recipe = buildRecipe();
      final copy = recipe.copyWith();

      expect(copy.title, recipe.title);
      expect(copy.rating, recipe.rating);
      expect(copy.ingredients, recipe.ingredients);
    });
  });

  group('Recipe のデフォルト値', () {
    // お気に入り状態は Recipe が持たない（favoriteIds が唯一の情報源）。
    test('difficulty は medium、tags / cookingTools は空', () {
      final recipe = buildRecipe();
      expect(recipe.difficulty, 'medium');
      expect(recipe.tags, isEmpty);
      expect(recipe.cookingTools, isEmpty);
    });
  });
}
