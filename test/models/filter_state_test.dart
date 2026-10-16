import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/models/filter_state.dart';

void main() {
  group('FilterState.initial', () {
    test('初期状態はフィルタ未適用（activeFilterCount == 0）', () {
      final state = FilterState.initial();

      expect(state.category, 'すべて');
      expect(state.searchQuery, '');
      expect(state.difficulties, isEmpty);
      expect(state.cookingTimeRange, isNull);
      expect(state.calorieRange, isNull);
      expect(state.minRating, isNull);
      expect(state.excludedAllergies, isEmpty);
      expect(state.selectedTags, isEmpty);
      expect(state.ingredientFilter, isNull);
      expect(state.activeFilterCount, 0);
    });
  });

  group('FilterState.activeFilterCount', () {
    test('各フィルタの適用ごとにカウントが増える', () {
      final state = FilterState.initial().copyWith(
        category: '和食',
        searchQuery: 'カレー',
        difficulties: {'easy'},
        cookingTimeRange: CookingTimeRange.under30,
        calorieRange: CalorieRange.low,
        minRating: 4.0,
        excludedAllergies: {'卵'},
        selectedTags: {'時短'},
        ingredientFilter: const IngredientFilter(mustInclude: {'鶏肉'}),
      );

      expect(state.activeFilterCount, 9);
    });

    test('空の IngredientFilter はカウントされない', () {
      final state = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(),
      );

      expect(state.activeFilterCount, 0);
    });

    test('category が「すべて」のときはカウントされない', () {
      final state = FilterState.initial().copyWith(category: 'すべて');

      expect(state.activeFilterCount, 0);
    });
  });

  group('FilterState.copyWith のクリアフラグ', () {
    test('clearCookingTimeRange で null に戻せる', () {
      final state = FilterState.initial().copyWith(
        cookingTimeRange: CookingTimeRange.under60,
      );
      expect(state.cookingTimeRange, CookingTimeRange.under60);

      final cleared = state.copyWith(clearCookingTimeRange: true);
      expect(cleared.cookingTimeRange, isNull);
    });

    test(
      'clearCalorieRange / clearMinRating / clearIngredientFilter が機能する',
      () {
        final state = FilterState.initial().copyWith(
          calorieRange: CalorieRange.medium,
          minRating: 3.5,
          ingredientFilter: const IngredientFilter(mustExclude: {'小麦'}),
        );

        final cleared = state.copyWith(
          clearCalorieRange: true,
          clearMinRating: true,
          clearIngredientFilter: true,
        );

        expect(cleared.calorieRange, isNull);
        expect(cleared.minRating, isNull);
        expect(cleared.ingredientFilter, isNull);
      },
    );

    test('指定しなかったフィールドは保持される', () {
      final state = FilterState.initial().copyWith(
        category: '中華',
        searchQuery: '麻婆',
      );

      final updated = state.copyWith(searchQuery: '麻婆豆腐');

      expect(updated.category, '中華');
      expect(updated.searchQuery, '麻婆豆腐');
    });
  });

  group('enum の定義値', () {
    test('CookingTimeRange の上限値', () {
      expect(CookingTimeRange.under30.maxMinutes, 30);
      expect(CookingTimeRange.under60.maxMinutes, 60);
      expect(CookingTimeRange.under120.maxMinutes, 120);
    });

    test('CalorieRange の上限値', () {
      expect(CalorieRange.low.maxCalories, 300);
      expect(CalorieRange.medium.maxCalories, 500);
    });
  });
}
