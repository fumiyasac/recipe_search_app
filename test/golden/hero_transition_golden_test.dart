@Tags(['golden'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/recipe_list_screen.dart';
import 'package:recipe_search_app/widgets/recipe_card.dart';

import '../support/network_image_mock.dart';

// ゴールデンは macOS（ローカル）でのみ生成・比較する。CI は ubuntu で、
// フォントのアンチエイリアス差により厳密一致しないため skip する（PR に方針を記載）。
// 生成:  flutter test --update-goldens --tags golden
// 比較:  flutter test --tags golden
void main() {
  final runGoldens = Platform.isMacOS;

  testWidgets('home→detail の遷移 0/25/50/75/100%', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // ネットワーク画像のデコード失敗（モックの 1x1 PNG）は golden の対象外なので無視する。
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('Codec failed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await provideMockNetworkImages(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
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

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump(); // 0%（遷移開始）
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/hero_000.png'),
      );

      for (final (i, ms) in [75, 75, 75, 75].indexed) {
        await tester.pump(Duration(milliseconds: ms));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/hero_${(i + 1) * 25}.png'),
        );
      }

      await tester.pumpAndSettle();
    });
  }, skip: !runGoldens);
}
