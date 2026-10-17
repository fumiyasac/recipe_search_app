import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// お気に入り状態の Single Source of Truth（favoriteIdsProvider）と、そこから
// 導出される favoriteRecipes / recipeFavoriteStatus の整合をインメモリ DB で検証する。
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    // 唯一の情報源 favoriteIds の watch Stream を起動して保持する
    final sub = container.listen(favoriteIdsProvider, (_, _) {});
    addTearDown(sub.close);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<Recipe> firstRecipe() async =>
      (await container.read(filteredRecipesProvider.future)).first;

  test('初期状態はすべて未お気に入り', () async {
    await container.read(favoriteIdsProvider.future);
    final target = await firstRecipe();

    expect(container.read(favoriteIdsProvider).value, isEmpty);
    expect(container.read(favoriteRecipesProvider), isEmpty);
    expect(container.read(recipeFavoriteStatusProvider(target.id)), isFalse);
  });

  test(
    'toggle で favoriteIds・favoriteRecipes・recipeFavoriteStatus が一括更新される',
    () async {
      final target = await firstRecipe();

      await container.read(recipeRepositoryProvider).toggleFavorite(target);
      await pumpEventQueue();

      // 同じ favoriteIds から導出されるので、すべて即座に反映される
      expect(container.read(favoriteIdsProvider).value, contains(target.id));
      expect(container.read(favoriteRecipesProvider).map((r) => r.id), [
        target.id,
      ]);
      expect(container.read(recipeFavoriteStatusProvider(target.id)), isTrue);
      expect(await db.isFavorite(target.id), isTrue);
    },
  );

  test('再 toggle ですべて未お気に入りに戻る', () async {
    final target = await firstRecipe();
    final repo = container.read(recipeRepositoryProvider);

    await repo.toggleFavorite(target);
    await pumpEventQueue();
    await repo.toggleFavorite(target);
    await pumpEventQueue();

    expect(container.read(favoriteIdsProvider).value, isEmpty);
    expect(container.read(favoriteRecipesProvider), isEmpty);
    expect(container.read(recipeFavoriteStatusProvider(target.id)), isFalse);
    expect(await db.isFavorite(target.id), isFalse);
  });
}
