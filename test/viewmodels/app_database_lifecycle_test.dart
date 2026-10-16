import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';

// appDatabaseProvider は keepAlive で、ref.onDispose(db.close) により
// ProviderContainer の破棄時に drift の接続が閉じられることを検証する。
//
// 本番の appDatabaseProvider は path_provider でファイルを開くため、Provider 本体を
// override で差し替えると「本番のライフサイクル」を検証できない。代わりに
// debugAppDatabaseFactory（本番 body が使う生成関数）だけをインメモリ DB に差し替え、
// appDatabaseProvider 本体（keepAlive + ref.onDispose）をそのまま実行させて検証する。
void main() {
  test(
    'ProviderContainer を dispose すると本番の appDatabaseProvider が close する',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      debugAppDatabaseFactory = () => db;
      addTearDown(() => debugAppDatabaseFactory = AppDatabase.new);

      // Provider は override しない（本番 body を実行させる）
      final container = ProviderContainer();

      // 本番 body が debugAppDatabaseFactory を使って同じ db を返す
      expect(container.read(appDatabaseProvider), same(db));
      // close 前はクエリできる
      expect(await db.getAllFavorites(), isEmpty);

      // コンテナ破棄で本番の ref.onDispose(db.close) が走る
      container.dispose();
      // close は非同期なので完了を待つ（クエリで例外になるまでポーリング）
      await _waitClosed(db);

      // close 後のクエリは例外になる
      await expectLater(db.getAllFavorites(), throwsA(anything));
    },
  );
}

// close() の完了を待つ（クエリが投げるようになるまで、最大 ~2 秒）
Future<void> _waitClosed(AppDatabase db) async {
  for (var i = 0; i < 40; i++) {
    try {
      await db.getAllFavorites();
    } catch (_) {
      return; // 閉じられた
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
