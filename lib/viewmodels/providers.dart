import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';

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
  Future<List<Recipe>> build(String category, String searchQuery) async {
    final repository = ref.watch(recipeRepositoryProvider);
    var recipes = await repository.getAllRecipes();

    // カテゴリフィルタ
    if (category != 'すべて') {
      recipes = recipes.where((r) => r.category == category).toList();
    }

    // 検索フィルタ
    if (searchQuery.isNotEmpty) {
      recipes = recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            recipe.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
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

// 選択中のカテゴリプロバイダー
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'すべて';

  void update(String category) {
    state = category;
  }
}

// 検索クエリプロバイダー
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
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
