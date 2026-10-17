import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// お気に入り解除の不具合に対する回帰テスト（Single Source of Truth 化後は PASS）。
//
// 以前は toggle が渡されたスナップショットの recipe.isFavorite で分岐し、一覧の
// 状態が古いまま残るため 2 回目も「追加」と判定されて主キー重複で例外になっていた。
// 現在は toggleFavorite が DB の現在状態で判定するため、一覧のスナップショットで
// 2 回呼んでも正しく解除される。
void main() {
  test('一覧(FilteredRecipes)の recipe で 2 回 toggle するとお気に入りが解除される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    // 唯一の情報源 favoriteIds を購読して watch Stream を起動する
    final sub = container.listen(favoriteIdsProvider, (_, _) {});
    addTearDown(sub.close);

    final repo = container.read(recipeRepositoryProvider);

    // 1 回目: 一覧から取得した recipe で登録
    final first = (await container.read(filteredRecipesProvider.future)).first;
    await repo.toggleFavorite(first);
    await pumpEventQueue();
    expect(await db.isFavorite(first.id), isTrue);
    expect(container.read(favoriteRecipesProvider).map((r) => r.id), [
      first.id,
    ]);

    // 2 回目: 一覧の同じスナップショットを渡しても、DB 状態で判定するので解除される
    final firstAgain = (await container.read(
      filteredRecipesProvider.future,
    )).first;
    await repo.toggleFavorite(firstAgain);
    await pumpEventQueue();

    expect(await db.isFavorite(first.id), isFalse);
    expect(container.read(favoriteRecipesProvider), isEmpty);
  });
}
