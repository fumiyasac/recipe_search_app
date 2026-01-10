import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../models/filter_state.dart';

part 'providers.g.dart';

// データベースプロバイダー
@riverpod
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

// レシピリポジトリプロバイダー
@riverpod
RecipeRepository recipeRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return RecipeRepository(database);
}

// 全レシピプロバイダー
@riverpod
class RecipeList extends _$RecipeList {
  @override
  Future<List<Recipe>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    return await repository.getAllRecipes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      return await repository.getAllRecipes();
    });
  }
}

// フィルタされたレシピプロバイダー
@riverpod
class FilteredRecipes extends _$FilteredRecipes {
  @override
  Future<List<Recipe>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    final filterState = ref.watch(recipeFilterStateProvider);

    var recipes = await repository.getAllRecipes();

    // 1. カテゴリフィルタ
    if (filterState.category != 'すべて') {
      recipes = recipes.where((r) => r.category == filterState.category).toList();
    }

    // 2. 検索クエリフィルタ
    if (filterState.searchQuery.isNotEmpty) {
      recipes = recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
            recipe.description.toLowerCase().contains(filterState.searchQuery.toLowerCase());
      }).toList();
    }

    // 3. 難易度フィルタ（OR条件）
    if (filterState.difficulties.isNotEmpty) {
      recipes = recipes.where((r) =>
        filterState.difficulties.contains(r.difficulty)
      ).toList();
    }

    // 4. 調理時間フィルタ
    if (filterState.cookingTimeRange != null) {
      recipes = recipes.where((r) =>
        r.totalTime <= filterState.cookingTimeRange!.maxMinutes
      ).toList();
    }

    // 5. カロリーフィルタ
    if (filterState.calorieRange != null) {
      recipes = recipes.where((r) =>
        r.calories <= filterState.calorieRange!.maxCalories
      ).toList();
    }

    // 6. 評価フィルタ
    if (filterState.minRating != null) {
      recipes = recipes.where((r) =>
        r.rating >= filterState.minRating!
      ).toList();
    }

    // 7. アレルギー除外フィルタ（AND条件: 指定アレルギーを含まない）
    if (filterState.excludedAllergies.isNotEmpty) {
      recipes = recipes.where((r) =>
        !r.allergies.any((a) => filterState.excludedAllergies.contains(a))
      ).toList();
    }

    // 8. タグフィルタ（AND条件: すべてのタグを含む）
    if (filterState.selectedTags.isNotEmpty) {
      recipes = recipes.where((r) =>
        filterState.selectedTags.every((tag) => r.tags.contains(tag))
      ).toList();
    }

    // 9. 材料フィルタ
    if (filterState.ingredientFilter != null) {
      if (filterState.ingredientFilter!.mustInclude.isNotEmpty) {
        recipes = recipes.where((r) =>
          filterState.ingredientFilter!.mustInclude.every((ingredient) =>
            r.ingredients.any((i) => i.toLowerCase().contains(ingredient.toLowerCase()))
          )
        ).toList();
      }

      if (filterState.ingredientFilter!.mustExclude.isNotEmpty) {
        recipes = recipes.where((r) =>
          !r.ingredients.any((i) =>
            filterState.ingredientFilter!.mustExclude.any((ingredient) =>
              i.toLowerCase().contains(ingredient.toLowerCase())
            )
          )
        ).toList();
      }
    }

    return recipes;
  }
}

// お気に入りレシピプロバイダー
@riverpod
class FavoriteRecipes extends _$FavoriteRecipes {
  @override
  Future<List<Recipe>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    return await repository.getFavoriteRecipes();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final repository = ref.read(recipeRepositoryProvider);

    if (recipe.isFavorite) {
      await repository.removeFromFavorites(recipe.id);
    } else {
      await repository.addToFavorites(recipe);
    }

    // レシピリストを更新
    ref.invalidate(recipeListProvider);

    // お気に入り状態プロバイダーを更新
    ref.invalidate(recipeFavoriteStatusProvider(recipe.id));

    // お気に入りリストを更新
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await repository.getFavoriteRecipes();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      return await repository.getFavoriteRecipes();
    });
  }
}

// フィルタ状態プロバイダー（新規）
@riverpod
class RecipeFilterState extends _$RecipeFilterState {
  @override
  FilterState build() => FilterState.initial();

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleDifficulty(String difficulty) {
    final newSet = Set<String>.from(state.difficulties);
    if (newSet.contains(difficulty)) {
      newSet.remove(difficulty);
    } else {
      newSet.add(difficulty);
    }
    state = state.copyWith(difficulties: newSet);
  }

  void updateCookingTimeRange(CookingTimeRange? range) {
    state = state.copyWith(
      cookingTimeRange: range,
      clearCookingTimeRange: range == null,
    );
  }

  void updateCalorieRange(CalorieRange? range) {
    state = state.copyWith(
      calorieRange: range,
      clearCalorieRange: range == null,
    );
  }

  void updateMinRating(double? rating) {
    state = state.copyWith(
      minRating: rating,
      clearMinRating: rating == null,
    );
  }

  void toggleAllergyExclusion(String allergy) {
    final newSet = Set<String>.from(state.excludedAllergies);
    if (newSet.contains(allergy)) {
      newSet.remove(allergy);
    } else {
      newSet.add(allergy);
    }
    state = state.copyWith(excludedAllergies: newSet);
  }

  void toggleTag(String tag) {
    final newSet = Set<String>.from(state.selectedTags);
    if (newSet.contains(tag)) {
      newSet.remove(tag);
    } else {
      newSet.add(tag);
    }
    state = state.copyWith(selectedTags: newSet);
  }

  void updateIngredientFilter(IngredientFilter? filter) {
    state = state.copyWith(
      ingredientFilter: filter,
      clearIngredientFilter: filter == null,
    );
  }

  void reset() {
    state = FilterState.initial();
  }
}

// 選択中のカテゴリプロバイダー（後方互換性のため）
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => ref.watch(recipeFilterStateProvider).category;

  void update(String category) {
    ref.read(recipeFilterStateProvider.notifier).updateCategory(category);
  }
}

// 検索クエリプロバイダー（後方互換性のため）
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => ref.watch(recipeFilterStateProvider).searchQuery;

  void update(String query) {
    ref.read(recipeFilterStateProvider.notifier).updateSearchQuery(query);
  }
}

// 月間カレンダー用ランダムレシピプロバイダー
@riverpod
class MonthlyRecipes extends _$MonthlyRecipes {
  @override
  Future<Map<DateTime, Recipe>> build(int year, int month) async {
    final repository = ref.watch(recipeRepositoryProvider);
    final allRecipes = await repository.getAllRecipes();

    final Map<DateTime, Recipe> monthlyRecipes = {};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      // ランダムにレシピを割り当て（日付をシードに使用して一貫性を保つ）
      final index = (date.year * 10000 + date.month * 100 + date.day) % allRecipes.length;
      monthlyRecipes[date] = allRecipes[index];
    }

    return monthlyRecipes;
  }
}

// 特定レシピのお気に入り状態プロバイダー
@riverpod
class RecipeFavoriteStatus extends _$RecipeFavoriteStatus {
  @override
  Future<bool> build(String recipeId) async {
    final repository = ref.watch(recipeRepositoryProvider);
    return await repository.isFavorite(recipeId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      return await repository.isFavorite(recipeId);
    });
  }
}

// 選択中のタブインデックスプロバイダー
@riverpod
class SelectedTabIndex extends _$SelectedTabIndex {
  @override
  int build() => 0; // デフォルトはホーム画面

  void update(int index) {
    state = index;
  }
}
