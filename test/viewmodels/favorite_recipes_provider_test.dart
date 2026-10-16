import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// FavoriteRecipes Provider（AsyncNotifier）のテスト。
//
// appDatabaseProvider をインメモリ DB（NativeDatabase.memory()）で差し替え、
// 実ファイルに触れずに drift を介したお気に入りの永続化を検証する。
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('初期状態ではお気に入りは空', () async {
    final favorites = await container.read(favoriteRecipesProvider.future);
    expect(favorites, isEmpty);
  });

  test('toggleFavorite でお気に入りが永続化される', () async {
    // リポジトリの既存レシピ（id は _getAllRecipes の値と一致する必要がある）
    final repository = container.read(recipeRepositoryProvider);
    final recipes = await repository.getAllRecipes();
    final target = recipes.first;
    expect(target.isFavorite, isFalse);

    await container
        .read(favoriteRecipesProvider.notifier)
        .toggleFavorite(target);

    final favorites = await container.read(favoriteRecipesProvider.future);
    expect(favorites.map((r) => r.id), contains(target.id));
    expect(favorites.every((r) => r.isFavorite), isTrue);

    // DB にも保存されていること
    expect(await db.isFavorite(target.id), isTrue);
  });

  test('toggleFavorite を 2 回呼ぶとお気に入りから外れる', () async {
    final repository = container.read(recipeRepositoryProvider);
    final recipes = await repository.getAllRecipes();
    final target = recipes.first;

    final notifier = container.read(favoriteRecipesProvider.notifier);
    await notifier.toggleFavorite(target);
    // 追加後の状態を反映した Recipe で再度トグル
    final added = (await container.read(favoriteRecipesProvider.future)).first;
    await notifier.toggleFavorite(added);

    final favorites = await container.read(favoriteRecipesProvider.future);
    expect(favorites, isEmpty);
    expect(await db.isFavorite(target.id), isFalse);
  });
}
