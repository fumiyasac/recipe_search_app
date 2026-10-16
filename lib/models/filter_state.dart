// 調理時間範囲
enum CookingTimeRange {
  under30(maxMinutes: 30, label: '30分以内'),
  under60(maxMinutes: 60, label: '1時間以内'),
  under120(maxMinutes: 120, label: '2時間以内');

  const CookingTimeRange({required this.maxMinutes, required this.label});

  final int maxMinutes;
  final String label;
}

// カロリー範囲
enum CalorieRange {
  low(maxCalories: 300, label: '低カロリー (300kcal以下)'),
  medium(maxCalories: 500, label: '中カロリー (500kcal以下)'),
  high(maxCalories: 99999, label: '制限なし');

  const CalorieRange({required this.maxCalories, required this.label});

  final int maxCalories;
  final String label;
}

// 材料フィルタ
class IngredientFilter {
  final Set<String> mustInclude;
  final Set<String> mustExclude;

  const IngredientFilter({
    this.mustInclude = const {},
    this.mustExclude = const {},
  });

  IngredientFilter copyWith({
    Set<String>? mustInclude,
    Set<String>? mustExclude,
  }) {
    return IngredientFilter(
      mustInclude: mustInclude ?? this.mustInclude,
      mustExclude: mustExclude ?? this.mustExclude,
    );
  }
}

// フィルタ状態を管理するモデル
class FilterState {
  // 既存フィルタ
  final String category;
  final String searchQuery;

  // 新規フィルタ
  final Set<String> difficulties;
  final CookingTimeRange? cookingTimeRange;
  final CalorieRange? calorieRange;
  final double? minRating;
  final Set<String> excludedAllergies;
  final Set<String> selectedTags;
  final IngredientFilter? ingredientFilter;

  const FilterState({
    this.category = 'すべて',
    this.searchQuery = '',
    this.difficulties = const {},
    this.cookingTimeRange,
    this.calorieRange,
    this.minRating,
    this.excludedAllergies = const {},
    this.selectedTags = const {},
    this.ingredientFilter,
  });

  FilterState copyWith({
    String? category,
    String? searchQuery,
    Set<String>? difficulties,
    CookingTimeRange? cookingTimeRange,
    bool clearCookingTimeRange = false,
    CalorieRange? calorieRange,
    bool clearCalorieRange = false,
    double? minRating,
    bool clearMinRating = false,
    Set<String>? excludedAllergies,
    Set<String>? selectedTags,
    IngredientFilter? ingredientFilter,
    bool clearIngredientFilter = false,
  }) {
    return FilterState(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      difficulties: difficulties ?? this.difficulties,
      cookingTimeRange: clearCookingTimeRange
          ? null
          : (cookingTimeRange ?? this.cookingTimeRange),
      calorieRange: clearCalorieRange
          ? null
          : (calorieRange ?? this.calorieRange),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      excludedAllergies: excludedAllergies ?? this.excludedAllergies,
      selectedTags: selectedTags ?? this.selectedTags,
      ingredientFilter: clearIngredientFilter
          ? null
          : (ingredientFilter ?? this.ingredientFilter),
    );
  }

  factory FilterState.initial() => const FilterState();

  // アクティブなフィルタ数（バッジ表示用）
  int get activeFilterCount {
    int count = 0;
    if (category != 'すべて') count++;
    if (searchQuery.isNotEmpty) count++;
    if (difficulties.isNotEmpty) count++;
    if (cookingTimeRange != null) count++;
    if (calorieRange != null) count++;
    if (minRating != null) count++;
    if (excludedAllergies.isNotEmpty) count++;
    if (selectedTags.isNotEmpty) count++;
    if (ingredientFilter != null &&
        (ingredientFilter!.mustInclude.isNotEmpty ||
            ingredientFilter!.mustExclude.isNotEmpty)) {
      count++;
    }
    return count;
  }
}
