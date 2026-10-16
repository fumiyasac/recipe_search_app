import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';

// 更新前（drift 2.30 / sqlite3 2.x）に作成した DB ファイル
// (test/migration/fixtures/legacy_v1.sqlite) を、更新後のコードで開いて
// データが読めることを検証する回帰テスト。
//
// sqlite3 2.x -> 3.x 移行や drift マイナー更新で既存 DB が壊れないことを担保する。
void main() {
  test('更新前に作成した legacy_v1.sqlite を開いてデータが読める', () async {
    final fixture = File('test/migration/fixtures/legacy_v1.sqlite');
    expect(
      fixture.existsSync(),
      isTrue,
      reason: 'フィクスチャが見つからない: ${fixture.path}',
    );

    // 元ファイルを壊さないよう一時ディレクトリへコピーして開く
    final tmpDir = Directory.systemTemp.createTempSync('legacy_db_test');
    final working = fixture.copySync('${tmpDir.path}/legacy_v1.sqlite');

    final db = AppDatabase.forTesting(NativeDatabase(working));
    addTearDown(() async {
      await db.close();
      tmpDir.deleteSync(recursive: true);
    });

    // schemaVersion は現行と同じ 1
    expect(db.schemaVersion, 1);

    final favorites = await db.getAllFavorites();
    expect(favorites, hasLength(1));

    final row = favorites.single;
    expect(row.id, 'legacy-1');
    expect(row.title, '旧バージョンのお気に入り');
    expect(row.rating, 4.5);
    expect(await db.isFavorite('legacy-1'), isTrue);
  });
}
