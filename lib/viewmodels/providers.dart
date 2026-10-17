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

// keepAlive: appDatabase / recipeRepository（リソース）と favoriteIds
//   （お気に入り状態の唯一の情報源。常駐させて全画面で共有する）。
// autoDispose（既定）: 以下は画面に紐づく一時状態・導出値。
// - RecipeList / FilteredRecipes / favoriteRecipes: 表示用の一覧。
// - recipeFavoriteStatus(recipeId) / MonthlyRecipes(year, month): family。
// - RecipeFilterState / SelectedCategory / SearchQuery / SelectedTabIndex: UI 状態。

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

// ── お気に入り状態の唯一の情報源（Single Source of Truth）──
//
// drift の watch() を keepAlive な Stream Provider として公開する。
// お気に入りに関する状態（詳細のハート・一覧のハート・お気に入りタブ）は
// すべてここから導出し、手作業の ref.invalidate は一切行わない。
// DB が変わるたびに Stream が新しい id 集合を流し、派生 Provider が自動更新される。
@Riverpod(keepAlive: true)
Stream<Set<String>> favoriteIds(Ref ref) {
  return ref.watch(recipeRepositoryProvider).watchFavoriteIds();
}

// お気に入りレシピ一覧（favoriteIds から導出）
@riverpod
List<Recipe> favoriteRecipes(Ref ref) {
  final ids = ref.watch(favoriteIdsProvider).value ?? const <String>{};
  final recipes = ref.watch(recipeRepositoryProvider).allRecipes();
  return recipes.where((r) => ids.contains(r.id)).toList();
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

// 特定レシピのお気に入り状態（favoriteIds から導出）。
// 画面のハートはこの Provider だけを見る。読み込み中は false を返す。
@riverpod
bool recipeFavoriteStatus(Ref ref, String recipeId) {
  final ids = ref.watch(favoriteIdsProvider).value ?? const <String>{};
  return ids.contains(recipeId);
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
