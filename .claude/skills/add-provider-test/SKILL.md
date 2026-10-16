---
name: add-provider-test
description: |
  指定した Riverpod Provider の単体テストを生成する。
  ProviderContainer で overrides を使い、drift には NativeDatabase.memory() を
  注入して実ファイルに触れずに検証する。AsyncNotifier は `.future` を await し、
  Notifier は `.notifier` 経由で操作して状態遷移を確認する。
  「Provider のテストを書いて」「〜Provider のテストを追加して」
  「ViewModel のテストがほしい」などのリクエストで使用する。
argument-hint: "<Provider名> (例: FavoriteRecipes / RecipeFavoriteStatus)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# add-provider-test — Provider テスト生成

対象 Provider を `lib/viewmodels/providers.dart` から特定し、
`test/viewmodels/<provider>_test.dart` にテストを作る。
drift を使う Provider は、`appDatabaseProvider` をインメモリ DB で差し替えるのが要点。

## 前提: テスト用コンストラクタ

`AppDatabase` には `AppDatabase.forTesting(QueryExecutor executor)` があり、
`NativeDatabase.memory()` を注入できる（`lib/database/database.dart`）。これを利用する。

## 手順

1. 対象 Provider の種別を確認する。
   - 関数プロバイダー（例 `appDatabase` / `recipeRepository`）: `container.read(xxxProvider)`
   - AsyncNotifier（例 `FavoriteRecipes` / `RecipeList`）: `await container.read(xxxProvider.future)`、操作は `container.read(xxxProvider.notifier)`
   - Notifier（例 `RecipeFilterState` / `SelectedTabIndex`）: `container.read(xxxProvider)` と `.notifier`
   - family（例 `recipeFavoriteStatus(recipeId)`）: `xxxProvider(arg)` で読む
2. `setUp` でインメモリ DB と `ProviderContainer` を用意し、`tearDown` で破棄する。
   ```dart
   late AppDatabase db;
   late ProviderContainer container;

   setUp(() {
     db = AppDatabase.forTesting(NativeDatabase.memory());
     container = ProviderContainer(
       overrides: [appDatabaseProvider.overrideWithValue(db)],
     );
   });
   tearDown(() async {
     container.dispose();
     await db.close();
   });
   ```
3. テストケースを書く（最低限）:
   - 初期状態（build の戻り値）
   - 状態を変える操作後の結果（Notifier のメソッド呼び出し）
   - drift を使う場合は DB 側にも反映されているか（`db.isFavorite(...)` 等）
   > 注意: `RecipeRepository` のレシピ ID はハードコード（`_getAllRecipes()`）。
   > お気に入り系のテストでは、リポジトリから取得した実在 ID の Recipe を使う。
4. 実行して通るまで修正する。
   ```bash
   flutter test test/viewmodels/<provider>_test.dart
   dart format . && flutter analyze
   ```

## 完了条件

- `test/viewmodels/<provider>_test.dart` が追加され、`flutter test` が成功する。
- `flutter analyze` が `No issues found!`（未使用 import などを残さない）。

## 失敗時の対処

| 症状 | 対処 |
|------|------|
| `getApplicationDocumentsDirectory` 例外 | 本物の `appDatabaseProvider` が使われている。`overrideWithValue` で `AppDatabase.forTesting` に差し替える。 |
| AsyncNotifier が loading のまま | `await container.read(xxxProvider.future)` で解決を待つ。 |
| お気に入りが反映されない | リポジトリの実在 ID（`getAllRecipes()` の値）を使っているか確認。 |
| `overrideWithValue` が使えない | 対象が Notifier の場合は `overrideWith`（ビルダ）を使う。関数/値 Provider は `overrideWithValue`。 |

## 参考実装

`test/viewmodels/favorite_recipes_provider_test.dart`（本スキルで生成した `FavoriteRecipes` の例）。
