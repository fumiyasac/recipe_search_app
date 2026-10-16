import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../models/filter_state.dart';

part 'providers.g.dart';

// データベースプロバイダー
//
// keepAlive: drift の AppDatabase は SQLite ファイルを開く長寿命のネイティブ
// リソース。autoDispose だと参照が一時的に途切れるたびに close されないまま
// 新しいインスタンスが生成され、同一ファイルを複数接続で開く恐れがある。
// アプリ単位のシングルトンとして保持し、コンテナ破棄時に必ず close する。
/// テストから差し替え可能な [AppDatabase] 生成関数。既定は本番のファイル DB。
/// これにより appDatabaseProvider 本体（keepAlive + onDispose）を上書きせずに、
/// インメモリ DB を注入して本番のライフサイクルをそのまま検証できる。
@visibleForTesting
AppDatabase Function() debugAppDatabaseFactory = AppDatabase.new;

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = debugAppDatabaseFactory();
  ref.onDispose(db.close);
  return db;
}

// レシピリポジトリプロバイダー
//
// keepAlive: keepAlive な AppDatabase をラップするだけの状態を持たない
// サービス。多数の Provider から watch されるため、autoDispose による
// 生成・破棄の繰り返しを避けてシングルトンとして共有する。
@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return RecipeRepository(database);
}

// これ以降の Provider は既定の autoDispose のままにする。
// - RecipeList / FilteredRecipes / FavoriteRecipes: 画面が参照する一時的な
//   表示状態。画面が消えたら破棄し、次回表示時に作り直すのが自然。
// - MonthlyRecipes(year, month) / RecipeFavoriteStatus(recipeId): family。
//   autoDispose にして引数ごとのキャッシュが無制限に増えるのを防ぐ。
// - RecipeFilterState / SelectedCategory / SearchQuery / SelectedTabIndex:
//   UI 状態。MainNavigationScreen の IndexedStack が常時 listen するため
//   実質セッション中保持され、保持すべき長寿命ネイティブリソースでもない。

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

    final recipes = await repository.getAllRecipes();

    // 絞り込みロジックは副作用のない純粋関数 applyFilters に切り出している
    // （lib/models/recipe_filter.dart）。テスト容易性のため Provider は呼ぶだけ。
    return applyFilters(recipes, filterState);
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
    state = state.copyWith(minRating: rating, clearMinRating: rating == null);
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
      final index =
          (date.year * 10000 + date.month * 100 + date.day) % allRecipes.length;
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
