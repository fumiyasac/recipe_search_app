import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// appDatabaseProvider は keepAlive で、ref.onDispose(db.close) により
// ProviderContainer の破棄時に drift の接続が閉じられることを検証する。
//
// 本番の appDatabaseProvider は path_provider でファイルを開くため単体テストでは
// 実体化できない。ここでは同じライフサイクル（onDispose で close）を持つ
// インメモリ DB を override で注入し、dispose 時に close されることを確認する。
void main() {
  test('ProviderContainer を dispose すると AppDatabase が close される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    var closeCalled = false;
    Future<void>? closeFuture;

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          // 本番と同じく破棄時に close する（呼ばれたことを検証できるよう記録）
          ref.onDispose(() {
            closeCalled = true;
            closeFuture = db.close();
          });
          return db;
        }),
      ],
    );

    // provider を実体化する
    expect(container.read(appDatabaseProvider), same(db));
    // close 前はクエリできる
    expect(await db.getAllFavorites(), isEmpty);

    // コンテナ破棄で onDispose が走り close される
    container.dispose();
    await closeFuture;

    // onDispose で close が呼ばれた
    expect(closeCalled, isTrue);
    // close 後のクエリは例外になる
    await expectLater(db.getAllFavorites(), throwsA(anything));
  });
}
