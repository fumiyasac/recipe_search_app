import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/recipe_list_screen.dart';

import '../support/network_image_mock.dart';

void main() {
  testWidgets('検索フィールドに入力すると一覧が絞り込まれる', (tester) async {
    await provideMockNetworkImages(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // drift の watch() を含む Provider を確実に破棄するため、コンテナを明示管理し
      // teardown で dispose する（ProviderScope の内部破棄だと保留中タイマーが残る）。
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      // 非同期の一覧読み込みを反映
      await tester.pumpAndSettle();

      // 初期状態では先頭行の複数レシピが表示される
      expect(find.text('和風カルボナーラ'), findsOneWidget);
      expect(find.text('トマトとモッツァレラのカプレーゼ'), findsOneWidget);

      // 検索バーに「カルボ」を入力
      await tester.enterText(find.byType(TextField).first, 'カルボ');
      await tester.pumpAndSettle();

      // 一致するものだけ残り、一致しないものは消える
      expect(find.text('和風カルボナーラ'), findsOneWidget);
      expect(find.text('トマトとモッツァレラのカプレーゼ'), findsNothing);
    });
  });

  testWidgets('該当しない検索語では空状態が表示される', (tester) async {
    await provideMockNetworkImages(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // drift の watch() を含む Provider を確実に破棄するため、コンテナを明示管理し
      // teardown で dispose する（ProviderScope の内部破棄だと保留中タイマーが残る）。
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '存在しない料理名');
      await tester.pumpAndSettle();

      expect(find.text('レシピが見つかりませんでした'), findsOneWidget);
    });
  });
}
