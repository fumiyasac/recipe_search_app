# アーキテクチャガイド

recipe_search_app の内部構造を図とともに解説します。概要・ルールは [CLAUDE.md](./CLAUDE.md)、セットアップは [README.md](./README.md) を参照してください。

## 目次

1. [システム全体像](#1-システム全体像)
2. [レイヤー構成](#2-レイヤー構成)
3. [状態管理（Riverpod）](#3-状態管理riverpod)
4. [データベース（drift）](#4-データベースdrift)
5. [画面遷移](#5-画面遷移)
6. [新機能を追加する際の標準手順](#6-新機能を追加する際の標準手順)

---

## 1. システム全体像

単一の Flutter モバイルアプリです。バックエンド／ネットワーク通信はなく、レシピのマスタデータは `RecipeRepository` 内にハードコードされています。永続化するのはお気に入り情報のみで、drift（SQLite）でローカル保存します。

```mermaid
graph LR
  User([ユーザー]) --> UI[Flutter UI<br/>HookConsumerWidget]
  UI --> VM[Riverpod Provider<br/>viewmodels]
  VM --> Repo[RecipeRepository]
  Repo --> Sample[ハードコードされた<br/>サンプルレシピ 16件]
  Repo --> DB[(drift / SQLite<br/>recipes.sqlite)]
```

---

## 2. レイヤー構成

MVVM + Repository パターンを `lib/` 配下のフォルダで表現しています。依存は上位（UI）から下位（データ）への一方向です。

```mermaid
graph TD
  Main[main.dart<br/>ProviderScope / MaterialApp]
  Views[views/<br/>画面 Widget]
  Widgets[widgets/<br/>再利用 UI 部品]
  VM[viewmodels/providers.dart<br/>Riverpod Provider 群]
  Repo[repositories/<br/>RecipeRepository]
  DB[database/<br/>AppDatabase drift]
  Models[models/<br/>Recipe / FilterState]

  Main --> Views
  Views --> Widgets
  Views --> VM
  Widgets --> VM
  VM --> Repo
  Repo --> DB
  Views -.使用.-> Models
  Widgets -.使用.-> Models
  Repo -.使用.-> Models
  VM -.使用.-> Models
```

### ディレクトリと責務

| パス | 責務 | 主な中身 |
|------|------|----------|
| `lib/main.dart` | エントリポイント | `ProviderScope`、`MaterialApp`（Material 3、シードカラー `#FF6B35`）、`home: MainNavigationScreen` |
| `lib/models/` | ドメイン／状態モデル（手書き、freezed 未使用）と純粋ロジック | `recipe.dart`（`Recipe` / `RecipeStep` / `RecipeComment` / `NutritionInfo`）、`filter_state.dart`（`FilterState` / `IngredientFilter` / `CookingTimeRange` / `CalorieRange`）、`recipe_filter.dart`（`applyFilters` — 9 段階の複合フィルタの純粋関数） |
| `lib/database/` | drift による永続化 | `FavoriteRecipes` テーブル、`AppDatabase`、生成物 `database.g.dart` |
| `lib/repositories/` | データソースの集約窓口 | `RecipeRepository`（サンプルレシピ + お気に入り DB の橋渡し、絞り込み・検索ヘルパー） |
| `lib/viewmodels/` | 状態管理 | `providers.dart`（`@riverpod` 定義）、生成物 `providers.g.dart` |
| `lib/views/` | 画面 | `main_navigation_screen` / `recipe_list_screen` / `favorites_screen` / `calendar_screen` / `recipe_detail_screen` |
| `lib/widgets/` | 再利用部品 | `recipe_card` / `filter_section` / `advanced_filter_sheet` / `nutrition_chart` |

- `nutrition_chart.dart` のみ `StatelessWidget`、それ以外の View / Widget はすべて `HookConsumerWidget`。
- `table_calendar` は `calendar_screen.dart` でのみ使用。
- `fl_chart`（`PieChart`）は `nutrition_chart.dart` でのみ使用（PFC バランスの円グラフ）。

---

## 3. 状態管理（Riverpod）

すべての Provider は `riverpod_annotation` の `@riverpod` アノテーションでコード生成しています（`providers.g.dart`）。手書き Provider は使用していません。

- **関数プロバイダー**: `appDatabase` / `recipeRepository`（インスタンスを提供）。DB は長寿命リソースのため **`@Riverpod(keepAlive: true)`** とし、`appDatabase` は `ref.onDispose(db.close)` で破棄時に接続を閉じる。それ以外の Provider は既定の autoDispose。
- **同期 Notifier**: `RecipeFilterState`（`FilterState`）、`SelectedCategory`、`SearchQuery`、`SelectedTabIndex`
- **非同期 AsyncNotifier（`Future` を `build`）**: `RecipeList`、`FilteredRecipes`、`MonthlyRecipes`（family: year, month）
- **お気に入り（Single Source of Truth）**: `favoriteIds`（`@Riverpod(keepAlive: true)` の **Stream Provider**。drift の `watchFavoriteIds()` を購読）が唯一の情報源。`favoriteRecipes`（一覧）と `recipeFavoriteStatus(recipeId)`（bool）は**ここから導出**する。追加/削除は `RecipeRepository.toggleFavorite(recipe)`（DB の現在状態をトランザクションで判定）に一本化し、手作業の `ref.invalidate` は行わない。
- `FilteredRecipes.build()` は複合フィルタを自前で持たず、純粋関数 `applyFilters`（`lib/models/recipe_filter.dart`）に委譲する（テスト容易性のため）。
- UI 側は `HookConsumerWidget` で `ref.watch` し、`useState` / `useTextEditingController` などの Hooks でローカル状態を扱う。

```mermaid
graph TD
  appDatabase[appDatabaseProvider<br/>AppDatabase · keepAlive]
  repo[recipeRepositoryProvider<br/>keepAlive]
  filterState[recipeFilterStateProvider<br/>Notifier FilterState]

  list[recipeListProvider]
  filtered[filteredRecipesProvider]
  monthly["monthlyRecipesProvider(year, month)"]

  favIds["favoriteIdsProvider<br/>Stream Set&lt;id&gt; · keepAlive · 唯一の情報源"]
  favRecipes[favoriteRecipesProvider<br/>導出]
  favStatus["recipeFavoriteStatusProvider(recipeId)<br/>導出 bool"]

  category[selectedCategoryProvider]
  query[searchQueryProvider]
  tab[selectedTabIndexProvider<br/>Notifier int]

  repo --> appDatabase
  list --> repo
  filtered --> repo
  filtered --> filterState
  monthly --> repo
  favIds --> repo
  favRecipes --> favIds
  favStatus --> favIds
  category --> filterState
  query --> filterState
```

> お気に入りは `favoriteIds`（drift の `watch()`）を唯一の情報源にし、`favoriteRecipes` と `recipeFavoriteStatus(id)` はそこから導出します。トグルは `RecipeRepository.toggleFavorite()` が DB の現在状態をトランザクションで判定して追加／削除するだけで、テーブルの変化を `watch()` が拾って派生 Provider を自動更新するため、**手作業の `invalidate` は不要**です。

### お気に入り: 修正前 → 修正後のデータフロー

```mermaid
flowchart TD
  subgraph B["修正前（不具合）"]
    b1[ハートをタップ] --> b2["toggleFavorite(recipe)"]
    b2 --> b3{"recipe.isFavorite?<br/>古いスナップショット"}
    b3 -->|常に false| b4["addFavorite（insert）"]
    b4 --> b5["2 回目は主キー重複で例外<br/>＝解除できない"]
    b2 -. 手作業 .-> b6[invalidate recipeList]
    b2 -. 手作業 .-> b7[invalidate favoriteStatus]
    b8["filteredRecipes は invalidate 対象外<br/>→ 一覧の isFavorite が古いまま"]
  end
```

```mermaid
flowchart TD
  subgraph A["修正後（Single Source of Truth）"]
    a1[ハートをタップ] --> a2["repo.toggleFavorite(recipe)"]
    a2 --> a3["transaction: DB の現在状態で<br/>add / remove を判定"]
    a3 --> a4["drift select().watch()"]
    a4 --> a5[favoriteIdsProvider 更新]
    a5 --> a6["recipeFavoriteStatus / favoriteRecipes<br/>が自動で最新化（invalidate 不要）"]
  end
```

---

## 4. データベース（drift）

`AppDatabase` は `FavoriteRecipes` の 1 テーブルのみを持ちます。DAO クラスは分離せず、クエリメソッドを `AppDatabase` に直接定義しています。DB ファイルは `path_provider` で取得したアプリのドキュメントディレクトリ配下の `recipes.sqlite`（`NativeDatabase` / `LazyDatabase`）です。

```mermaid
erDiagram
  FavoriteRecipes {
    TEXT id PK
    TEXT title
    TEXT description
    TEXT imageUrl
    TEXT category
    INTEGER prepTime
    INTEGER cookTime
    INTEGER servings
    INTEGER calories
    REAL rating
    TEXT ingredients "JSON 文字列"
    TEXT steps "JSON 文字列"
    TEXT allergies "JSON 文字列"
    DATETIME savedAt
  }
```

- `schemaVersion = 1`。**`MigrationStrategy`（`onUpgrade`）は未定義**で、drift の既定動作に依存しています。
- `ingredients` / `steps` / `allergies` は `jsonEncode` した JSON 文字列として単一カラムに格納（正規化していない）。
- レシピのマスタデータは DB に入っておらず、`RecipeRepository._getAllRecipes()` のハードコードが真実の源。DB はお気に入りの id 集合＋表示用スナップショットのみ保持します。

> ⚠️ テーブルを変更する際は、必ず `schemaVersion` を上げ、`MigrationStrategy` を実装してください（[CLAUDE.md](./CLAUDE.md) の「守るべきルール」参照）。現状は未整備のため、スキーマ変更時の既存データ移行が課題です。

---

## 5. 画面遷移

ボトムナビゲーション（3 タブ）を `IndexedStack` で保持します。詳細画面へは複数の遷移元
（ホーム一覧・お気に入り・カレンダー）から遷移でき、**遷移処理は 1 箇所に集約**しています。
名前付きルーティング（go_router 等）は未導入です。

- **遷移ヘルパー**: `RecipeDetailScreen.route(context, recipe, source, {tagKey})` に集約。
  `MaterialPageRoute` を生成し、「視差効果を減らす」設定時は遷移時間ゼロにする。
- **Hero**: 画像は共通部品 `RecipeHeroImage`（Hero で包むのは画像だけ）で表示する。
  タグは `RecipeHeroTag.image(id, source, key)` で生成し、遷移元（home/favorites/calendar）
  と識別子を含めて一意化する（IndexedStack の複数タブ／同一画面の重複を防ぐ）。
  詳細の情報カードは Hero の外でフェード表示し、`flightShuttleBuilder` で角丸を補間する。

```mermaid
graph TD
  Main[MainNavigationScreen<br/>IndexedStack + BottomNavigationBar]
  List[RecipeListScreen<br/>ホーム]
  Fav[FavoritesScreen<br/>お気に入り]
  Cal[CalendarScreen<br/>カレンダー]
  Route["RecipeDetailScreen.route()<br/>遷移処理を集約・Hero 画像"]
  Detail[RecipeDetailScreen]
  Sheet[AdvancedFilterSheet<br/>ModalBottomSheet]

  Main --> List
  Main --> Fav
  Main --> Cal
  List -->|"RecipeCard（source: home）"| Route
  Fav -->|"RecipeCard（source: favorites）"| Route
  Cal -->|"カード/一覧（source: calendar, tagKey）"| Route
  Route -->|Hero 画像でつながる| Detail
  List -->|FilterSection の絞り込み| Sheet
```

---

## 6. 新機能を追加する際の標準手順

1. **モデル** — 必要なら `lib/models/` にクラスを追加／拡張する（手書き、`copyWith` の慣習に合わせる）。
2. **永続化が必要な場合** — `lib/database/database.dart` のテーブルを変更し、`schemaVersion` を上げて `MigrationStrategy` を実装 → `dart run build_runner build --delete-conflicting-outputs`。
3. **データアクセス** — `RecipeRepository` にメソッドを追加する（View / Provider から DB を直接触らない）。
4. **状態管理** — `lib/viewmodels/providers.dart` に `@riverpod` で Provider / Notifier / AsyncNotifier を追加 → コード生成を実行し `providers.g.dart` をコミット。
5. **UI** — 画面は `lib/views/`、再利用部品は `lib/widgets/` に `HookConsumerWidget` で追加。`ref.watch` で状態を購読し、ローカル状態は Hooks で扱う。
6. **画面遷移** — 既存の `Navigator.push`（`MaterialPageRoute`）の慣習に合わせる。
7. **検証** — `flutter analyze` / `dart format` / `flutter test` を実行。生成物を含めてコミットする。
