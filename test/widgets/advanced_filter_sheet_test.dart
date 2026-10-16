import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/widgets/advanced_filter_sheet.dart';

import '../support/network_image_mock.dart';

void main() {
  testWidgets('難易度フィルタを適用すると絞り込み結果が変わる', (tester) async {
    await provideMockNetworkImages(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      // 適用前は全 16 件
      final before = await container.read(filteredRecipesProvider.future);
      expect(before, hasLength(16));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: AdvancedFilterSheet())),
        ),
      );
      await tester.pumpAndSettle();

      // 「難易度」セクションを展開して「簡単」を選択
      await tester.tap(find.text('難易度'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('簡単'));
      await tester.pumpAndSettle();

      // フィルタ状態が更新され、結果が減って全て easy になる
      final filterState = container.read(recipeFilterStateProvider);
      expect(filterState.difficulties, contains('easy'));

      final after = await container.read(filteredRecipesProvider.future);
      expect(after.length, lessThan(before.length));
      expect(after.every((r) => r.difficulty == 'easy'), isTrue);
    });
  });
}
