---
name: add-feature
description: |
  既存の MVVM + Repository 構成に沿って新機能の雛形を生成する。
  モデル → （必要なら）drift テーブル/クエリ → Repository メソッド →
  @riverpod Provider → Screen/Widget（HookConsumerWidget）の順に、
  既存実装から抽出したテンプレートで追加する。
  「新機能を追加して」「〜画面を作って」「〜一覧機能がほしい」
  などのリクエストで使用する。
argument-hint: "<機能名> (例: shopping_list)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# add-feature — 新機能スキャフォールド

`<機能名>`（snake_case）を受け取り、[architecture_guidance.md](../../../architecture_guidance.md) の
「新機能を追加する際の標準手順」に沿って下から上の順に雛形を追加する。
クラス名は PascalCase、ファイル名は snake_case（[CLAUDE.md](../../../CLAUDE.md) の命名規約）。

## 手順

まず既存実装を読み、最新のパターンをテンプレート源にする（ハードコードせず都度抽出）。
- モデル: `lib/models/recipe.dart`
- DB: `lib/database/database.dart`
- Repository: `lib/repositories/recipe_repository.dart`
- Provider: `lib/viewmodels/providers.dart`
- Screen: `lib/views/recipe_list_screen.dart` / Widget: `lib/widgets/recipe_card.dart`

### 1. モデル（`lib/models/<機能名>.dart`）
手書きの素の Dart クラス。`copyWith` を用意する（freezed は使わない）。

```dart
class <Feature> {
  final String id;
  // ... フィールド
  const <Feature>({required this.id /* , ... */});

  <Feature> copyWith({String? id /* , ... */}) =>
      <Feature>(id: id ?? this.id /* , ... */);
}
```

### 2. 永続化が必要な場合のみ：drift テーブル & クエリ
`lib/database/database.dart` にテーブルを追加し `@DriftDatabase(tables: [...])` に登録。
**テーブル変更は必ず [drift-schema-change](../drift-schema-change/SKILL.md) の手順で行う**
（schemaVersion のインクリメントと MigrationStrategy が必須）。クエリは `AppDatabase` に直接メソッドとして追加。

### 3. Repository（`lib/repositories/` に追記 or 新規）
DB アクセスと一覧の取得・絞り込みを集約する。View / Provider から DB を直接触らせない。

```dart
class <Feature>Repository {
  final AppDatabase _database;
  <Feature>Repository(this._database);
  Future<List<<Feature>>> getAll() async { /* ... */ }
}
```

### 4. Provider（`lib/viewmodels/providers.dart` に追記）
`@riverpod` で生成。インスタンス提供は関数プロバイダー、非同期一覧は AsyncNotifier（`Future<T>` を `build`）、同期状態は Notifier。

```dart
@riverpod
<Feature>Repository <feature>Repository(Ref ref) =>
    <Feature>Repository(ref.watch(appDatabaseProvider));

@riverpod
class <Feature>List extends _$<Feature>List {
  @override
  Future<List<<Feature>>> build() async =>
      ref.watch(<feature>RepositoryProvider).getAll();
}
```
追加後は [codegen](../codegen/SKILL.md) を実行して `providers.g.dart` を再生成する。

### 5. Screen / Widget
画面は `lib/views/<機能名>_screen.dart`、再利用部品は `lib/widgets/` に
`HookConsumerWidget` で追加。非同期は `ref.watch(...).when(data/loading/error)` で分岐、
ローカル状態は `flutter_hooks`（`useState` 等）で扱う。一覧は `recipe_list_screen.dart` の
`CustomScrollView` + `.when` パターンを踏襲。

### 6. 画面遷移・検証
遷移は既存の `Navigator.push(MaterialPageRoute(...))` 慣習に合わせる。最後に検証する。
```bash
dart run build_runner build --delete-conflicting-outputs
dart format . && flutter analyze && flutter test
```

## 完了条件

- 追加した層が既存の命名・配置規約に一致している。
- `flutter analyze` が `No issues found!`、`flutter test` が成功、生成物の差分をコミット済み。

## 失敗時の対処

| 症状 | 対処 |
|------|------|
| Provider が未定義（`...Provider` が無い） | [codegen](../codegen/SKILL.md) を実行して再生成する。 |
| drift のスキーマ変更でビルドエラー | [drift-schema-change](../drift-schema-change/SKILL.md) の手順に戻る。 |
| 画面で非同期の `loading`/`error` 未処理 | `AsyncValue.when` の 3 分岐を必ず実装する。 |
| 生成テストが無い | [add-provider-test](../add-provider-test/SKILL.md) で Provider テストを追加する。 |
