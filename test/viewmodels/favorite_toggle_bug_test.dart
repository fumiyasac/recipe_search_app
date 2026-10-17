import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// お気に入り解除の不具合（Single Source of Truth 化前）を再現する Provider テスト。
//
// 仮説: toggleFavorite が渡されたスナップショットの recipe.isFavorite で分岐し、
// FilteredRecipes は invalidate されないため一覧の isFavorite が古いまま残る。
// その結果、一覧から取得した recipe で 2 回 toggle すると、2 回目も「追加」と判定され、
// 主キー重複で例外になる（＝解除できない）。
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

    final notifier = container.read(favoriteRecipesProvider.notifier);

    // 1 回目: 一覧から取得した recipe で登録
    final first = (await container.read(filteredRecipesProvider.future)).first;
    await notifier.toggleFavorite(first);
    expect(await db.isFavorite(first.id), isTrue);

    // 2 回目: 一覧を見ている UI は同じスナップショット（isFavorite は古いまま）を渡す。
    // 本来は解除されるべき。
    final firstAgain = (await container.read(
      filteredRecipesProvider.future,
    )).first;
    await notifier.toggleFavorite(firstAgain);

    expect(await db.isFavorite(first.id), isFalse);
    expect(await container.read(favoriteRecipesProvider.future), isEmpty);
  });
}
