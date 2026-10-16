---
name: codegen
description: |
  build_runner を実行して Riverpod（@riverpod）と drift の *.g.dart を再生成する。
  生成エラーが出た場合は原因を特定して修正し、生成が通るまで繰り返す。
  「コード生成して」「build_runner を回して」「.g.dart を作り直して」
  「riverpod / drift の生成が壊れた」などのリクエストで使用する。
argument-hint: "(引数なし)"
allowed-tools:
  - Read
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# codegen — コード生成の実行と修復

`@riverpod`（`lib/viewmodels/providers.dart`）と drift（`lib/database/database.dart`）の
生成物 `providers.g.dart` / `database.g.dart` を再生成する。本リポジトリは `*.g.dart` を
Git 管理する方針なので、生成結果は必ずコミット対象に含める（[CLAUDE.md](../../../CLAUDE.md) 参照）。

## 手順

1. 依存が解決済みか確認する。未解決なら解決する。
   ```bash
   flutter pub get
   ```
2. コード生成を実行する。
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. 生成が失敗した場合、ログの最初のエラーから原因を特定して修正する（下記「失敗時の対処」）。
   修正したら手順 2 を再実行する。成功するまで繰り返す。
4. 生成が通ったら、解析とフォーマットで健全性を確認する。
   ```bash
   flutter analyze
   dart format .
   ```
5. 生成物に差分が出たか確認する（コミット漏れ防止）。
   ```bash
   git status --porcelain -- '*.g.dart'
   ```

## 完了条件

- `dart run build_runner build --delete-conflicting-outputs` が `Built with build_runner` で正常終了する。
- `flutter analyze` が `No issues found!`。
- 生成された `*.g.dart` の差分がある場合は、変更元の `.dart` と同じコミットに含める。

## 失敗時の対処

| 症状 | 原因 / 対処 |
|------|-------------|
| `Conflicting outputs were detected` | `--delete-conflicting-outputs` を付けて再実行する。 |
| `part 'xxx.g.dart';` 不足で生成されない | 対象ファイル先頭の `part '<basename>.g.dart';` 宣言を確認・追加する。 |
| `@riverpod` クラスの型エラー | Notifier は同期型を、AsyncNotifier は `Future<T>` を `build` が返しているか確認する。family 引数の型変更時は参照側も更新する。 |
| drift のテーブル／カラム型エラー | `lib/database/database.dart` の `Table` 定義（`TextColumn get x => text()();` 等）の構文を確認する。スキーマ変更は [drift-schema-change](../drift-schema-change/SKILL.md) の手順に従う。 |
| `watch` が終わらない／古い生成物が残る | `dart run build_runner clean` 後に再度 `build` する。 |
