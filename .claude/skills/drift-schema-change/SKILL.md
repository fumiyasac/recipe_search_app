---
name: drift-schema-change
description: |
  drift のスキーマ変更を安全に一貫して行う最重要スキル。
  テーブル変更 → schemaVersion のインクリメント → MigrationStrategy の onUpgrade 追記
  → スキーマのダンプ（drift_dev schema dump）→ マイグレーションテスト追加 → codegen
  までを順に実施する。既存端末のデータ破損を防ぐため、カラム追加・変更・削除を
  伴う作業では必ずこのスキルを使う。
  「テーブルにカラムを追加して」「drift のスキーマを変えて」「DB の構造を変更して」
  「schemaVersion を上げて」「マイグレーションを書いて」などで使用する。
argument-hint: "<変更内容> (例: FavoriteRecipes に memo カラムを追加)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# drift-schema-change — スキーマ変更の一貫フロー

対象: `lib/database/database.dart`（`AppDatabase` / テーブル定義）。
本スキルの目的は **「schemaVersion の更新」と「MigrationStrategy」を絶対に飛ばさない** こと。
現状 `schemaVersion = 1` で `MigrationStrategy` 未定義のため、初回のスキーマ変更時に
`onUpgrade` を新設する（[architecture_guidance.md](../../../architecture_guidance.md) 第 4 章 / [CLAUDE.md](../../../CLAUDE.md) 参照）。

> ⚠️ 破壊的操作の注意: このスキルはスキーマを変更する。実行前に現状を確認し、
> 変更内容をユーザーに要約してから進める。`--dry-run` 指定時は変更を書かず手順のみ提示する。

## 手順

### 0. 事前確認
- `lib/database/database.dart` を読み、現在の `schemaVersion` とテーブル定義を把握する。
- 変更の種類（カラム追加 / 型変更 / テーブル追加 / 削除）を特定する。

### 1. テーブル定義の変更
対象テーブルに変更を加える。例: 列の追加（既存行があるため NULL 許容かデフォルトを付ける）。
```dart
// 追加カラムは nullable か withDefault にして既存行の移行を安全にする
TextColumn get memo => text().nullable()();
```

### 2. schemaVersion をインクリメント
```dart
@override
int get schemaVersion => 2; // 1 -> 2
```

### 3. MigrationStrategy の onUpgrade を追記（未定義なら新設）
```dart
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(favoriteRecipes, favoriteRecipes.memo);
        }
      },
    );
```
`from` のバージョン境界ごとに `if (from < N)` で段階的に積み上げる（スキップ更新に耐える形）。

### 4. スキーマのダンプ
変更後の schemaVersion を JSON として書き出し、履歴として管理する。
```bash
dart run drift_dev schema dump lib/database/database.dart drift_schemas/
```
`drift_schemas/drift_schema_v<N>.json` が生成される（v1 が無い場合は、まず旧定義で v1 をダンプしてから変更するのが理想。初回は現状を v1 として残す）。

### 5. マイグレーションテストの生成と追加
テスト用ヘルパーを生成する。
```bash
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```
`test/migration_test.dart` を作成し、旧バージョンの DB を作って `migrateTo` し、
`SchemaVerifier` で整合を検証する。
```dart
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 マイグレーション', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });
}
```

### 6. codegen
```bash
dart run build_runner build --delete-conflicting-outputs
```
（[codegen](../codegen/SKILL.md) スキルに委譲してもよい）

### 7. 検証
```bash
dart format . && flutter analyze && flutter test
```

## 完了条件

- テーブル変更・`schemaVersion` インクリメント・`onUpgrade` 追記がすべて揃っている
  （どれか一つでも欠けていれば未完了）。
- `drift_schemas/` に新バージョンの JSON がある。
- マイグレーションテストが追加され `flutter test` が成功する。
- `database.g.dart` を再生成しコミット対象に含めた。

## 失敗時の対処

| 症状 | 対処 |
|------|------|
| `drift_dev schema dump` が見つからない | dev_dependencies に `drift_dev` があるか確認（本リポジトリは導入済み）。`flutter pub get` 後に再実行。 |
| マイグレーションテストが落ちる | `onUpgrade` の列追加・テーブル作成が schemaVersion と一致しているか、`if (from < N)` の境界を確認。 |
| 既存行でクラッシュ（NOT NULL 制約） | 追加カラムを `.nullable()` か `.withDefault(...)` にする。 |
| schemaVersion を上げ忘れた | drift は同一バージョンだと `onUpgrade` を呼ばない。必ずインクリメントする。 |

## --dry-run（検証用）

`--dry-run` 指定時はファイルを一切変更せず、上記 1〜7 を対象ファイルの現状に当てはめた
具体的な手順（変更差分の要約・追加予定コマンド・作成するテストファイル名）だけを出力する。
