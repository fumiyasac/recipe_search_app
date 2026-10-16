import 'recipe.dart';
import 'filter_state.dart';

/// [FilterState] に基づいて [recipes] を絞り込む純粋関数。
///
/// 副作用はなく、入力リストを変更しない（毎段階で新しいリストを返す）。
/// 9 段階のフィルタを順に適用する。各フィルタは未指定なら素通しする。
///
/// 条件の種別:
/// - カテゴリ / 検索 / 調理時間 / カロリー / 評価: 絞り込み（AND で連結）
/// - 難易度: **OR**（選択したいずれかに一致）
/// - アレルギー除外: 指定アレルギーを 1 つでも含めば除外
/// - タグ / 材料(含む): **AND**（選択したすべてを含む）
/// - 材料(除く): 指定材料を 1 つでも含めば除外
///
/// 検索・材料の文字列比較は大文字小文字を無視する（`toLowerCase`）。
List<Recipe> applyFilters(List<Recipe> recipes, FilterState filterState) {
  var result = recipes;

  // 1. カテゴリフィルタ
  if (filterState.category != 'すべて') {
    result = result.where((r) => r.category == filterState.category).toList();
  }

  // 2. 検索クエリフィルタ
  if (filterState.searchQuery.isNotEmpty) {
    final query = filterState.searchQuery.toLowerCase();
    result = result.where((recipe) {
      return recipe.title.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query);
    }).toList();
  }

  // 3. 難易度フィルタ（OR条件）
  if (filterState.difficulties.isNotEmpty) {
    result = result
        .where((r) => filterState.difficulties.contains(r.difficulty))
        .toList();
  }

  // 4. 調理時間フィルタ
  if (filterState.cookingTimeRange != null) {
    result = result
        .where((r) => r.totalTime <= filterState.cookingTimeRange!.maxMinutes)
        .toList();
  }

  // 5. カロリーフィルタ
  if (filterState.calorieRange != null) {
    result = result
        .where((r) => r.calories <= filterState.calorieRange!.maxCalories)
        .toList();
  }

  // 6. 評価フィルタ
  if (filterState.minRating != null) {
    result = result.where((r) => r.rating >= filterState.minRating!).toList();
  }

  // 7. アレルギー除外フィルタ（AND条件: 指定アレルギーを含まない）
  if (filterState.excludedAllergies.isNotEmpty) {
    result = result
        .where(
          (r) => !r.allergies.any(
            (a) => filterState.excludedAllergies.contains(a),
          ),
        )
        .toList();
  }

  // 8. タグフィルタ（AND条件: すべてのタグを含む）
  if (filterState.selectedTags.isNotEmpty) {
    result = result
        .where(
          (r) => filterState.selectedTags.every((tag) => r.tags.contains(tag)),
        )
        .toList();
  }

  // 9. 材料フィルタ
  if (filterState.ingredientFilter != null) {
    if (filterState.ingredientFilter!.mustInclude.isNotEmpty) {
      result = result
          .where(
            (r) => filterState.ingredientFilter!.mustInclude.every(
              (ingredient) => r.ingredients.any(
                (i) => i.toLowerCase().contains(ingredient.toLowerCase()),
              ),
            ),
          )
          .toList();
    }

    if (filterState.ingredientFilter!.mustExclude.isNotEmpty) {
      result = result
          .where(
            (r) => !r.ingredients.any(
              (i) => filterState.ingredientFilter!.mustExclude.any(
                (ingredient) =>
                    i.toLowerCase().contains(ingredient.toLowerCase()),
              ),
            ),
          )
          .toList();
    }
  }

  return result;
}
