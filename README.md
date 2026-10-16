# recipe_search_app

[![CI](https://github.com/fumiyasac/recipe_search_app/actions/workflows/ci.yml/badge.svg)](https://github.com/fumiyasac/recipe_search_app/actions/workflows/ci.yml)

レシピを検索・絞り込み・お気に入り登録し、カレンダーや栄養バランスで楽しむFlutter製のモバイルアプリです。レシピのマスタデータはアプリ内に同梱され、お気に入りのみdrift（SQLite）でローカルに永続化します。

## このリポジトリの見どころ

### UI・機能

- **9 条件の複合フィルタ** — カテゴリ・キーワード・難易度(OR)・調理時間・カロリー・評価・アレルギー除外・タグ(AND)・材料(含む/除く) を組み合わせて絞り込み。ロジックは純粋関数 `applyFilters` に切り出し、テストカバレッジ 100%。
- **カレンダー献立** — `table_calendar` で日付ごとのおすすめレシピを表示。
- **PFC 栄養グラフ** — `fl_chart` のドーナツグラフでタンパク質・脂質・炭水化物の比率を可視化。

（[スクリーンショット](#スクリーンショット)も参照）

### AI 駆動開発の履歴

本リポジトリは Claude Code を使い、1 PR = 1 テーマで段階的に育てています。

| PR | テーマ |
|----|--------|
| [#1](https://github.com/fumiyasac/recipe_search_app/pull/1) | AI 駆動開発の土台（CLAUDE.md / architecture_guidance.md / README）を整備 |
| [#2](https://github.com/fumiyasac/recipe_search_app/pull/2) | 品質ゲート（GitHub Actions / Git フック / mise / Claude 設定）を導入 |
| [#3](https://github.com/fumiyasac/recipe_search_app/pull/3) | Claude Code の Skill / Subagent を追加（[skill_guidance.md](./skill_guidance.md)） |
| [#4](https://github.com/fumiyasac/recipe_search_app/pull/4) | Flutter 3.47.7 と依存パッケージを安全に更新 |
| [#5](https://github.com/fumiyasac/recipe_search_app/pull/5) | スクリーンショット掲載とネイティブビルド差分の取り込み |
| [#6](https://github.com/fumiyasac/recipe_search_app/pull/6) | ショーケース品質化（Provider ライフサイクル修正 / フィルタ切り出し＋テスト拡充 / code-reviewer 改善 / 画面キャプチャ / ドキュメント整合）※本 PR |

## 主な機能

- 🔎 **レシピ一覧・検索** — タイトル／説明文からのキーワード検索とカテゴリ切り替え
- 🧰 **詳細な絞り込み** — 難易度・調理時間・カロリー・評価・アレルギー除外・タグ・材料（含む／除く）の複合フィルタ
- ⭐ **お気に入り** — drift（SQLite）でローカル保存、一覧から素早く再アクセス
- 📅 **カレンダー** — `table_calendar`で日付ごとのおすすめレシピを表示
- 📊 **栄養バランス** — `fl_chart`の円グラフでPFC（タンパク質・脂質・炭水化物）を可視化
- 📝 **レシピ詳細** — 材料・手順・栄養情報・コメントを表示

## スクリーンショット

実機相当（Android エミュレータ API 36）で撮影した主要画面です。

| ホーム（一覧・検索） | 詳細フィルタ | レシピ詳細 | 栄養グラフ（PFC） | カレンダー |
|:---:|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/android_home.png" width="160" alt="ホーム画面"> | <img src="docs/screenshots/filter_sheet.png" width="160" alt="詳細フィルタシート"> | <img src="docs/screenshots/detail.png" width="160" alt="レシピ詳細"> | <img src="docs/screenshots/nutrition.png" width="160" alt="栄養グラフ"> | <img src="docs/screenshots/calendar.png" width="160" alt="カレンダー"> |

### 操作デモ（GIF）

「検索 → 詳細フィルタ適用 → レシピ詳細を開く」の操作デモです。GIF は `ffmpeg` が必要なため、[docs/screenshots/CAPTURE_GUIDE.md](docs/screenshots/CAPTURE_GUIDE.md) の手順で `docs/screenshots/demo.gif` を生成すると下に表示されます。

<img src="docs/screenshots/demo.gif" width="320" alt="操作デモ GIF">

> iOS（iPhone 15 Pro）でも同一 UI で動作します。各画面の撮影方法・ファイル名・GIF 生成手順は [CAPTURE_GUIDE.md](docs/screenshots/CAPTURE_GUIDE.md) を参照してください。

## 前提条件

| ツール | バージョン | 確認コマンド |
|--------|-----------|--------------|
| Flutter | 3.47.7（`.mise.toml`で固定） | `flutter --version` |
| Dart | 3.13.x（pubspecの`sdk: ^3.10.4`を満たすこと） | `dart --version` |
| iOS開発 | Xcode（Macのみ） | `xcodebuild -version` |
| Android開発 | Android Studio / Android SDK | — |
| mise（任意・推奨） | 最新 | `mise --version` |

環境が整っているかは`flutter doctor`で確認できます。

### miseによるツールバージョン管理（任意・推奨）

`.mise.toml`でFlutterのバージョン（3.47.7）を固定しています。[mise](https://mise.jdx.dev/)を導入すると、チーム・CIと同一バージョンのFlutterを自動で用意できます。

```bash
# mise のインストール（macOS / Homebrew の例）
brew install mise
# シェル連携（zsh の例。詳細は mise 公式ドキュメント参照）
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# リポジトリルートで実行すると .mise.toml のバージョンが導入される
mise install
```

miseを使わない場合も、Flutter 3.47.7（stable）を手動で用意すれば動作します。

## クイックスタート

```bash
# 1. リポジトリを取得
git clone git@github.com:fumiyasac/recipe_search_app.git
cd recipe_search_app

# 2. ツールバージョンを導入（mise 利用時。未使用なら Flutter 3.47.7 を手動で用意）
mise install

# 3. Git フックを有効化（コミット時に dart format を自動実行）
sh scripts/setup-hooks.sh

# 4. 依存関係を解決
flutter pub get

# 5. コード生成（*.g.dart を生成）
dart run build_runner build --delete-conflicting-outputs

# 6. 実行（接続中のデバイス／シミュレータで起動）
flutter run
```

> `*.g.dart`（`providers.g.dart` / `database.g.dart`）はGit管理されているため、クローン直後でもビルドは可能です。ソースを変更した際は手順5を再実行してください。

## 開発コマンド

```bash
# 依存解決
flutter pub get

# コード生成（1 回）
dart run build_runner build --delete-conflicting-outputs
# コード生成（監視モード）
dart run build_runner watch --delete-conflicting-outputs

# 静的解析
flutter analyze

# フォーマット（チェックのみ。CI と同じ全体チェック）
dart format --output=none --set-exit-if-changed .
# フォーマット（書き込み）
dart format .

# テスト
flutter test
# テスト（カバレッジ出力。coverage/lcov.info を生成）
flutter test --coverage

# 実行
flutter run

# ツールバージョンの導入（mise 利用時）
mise install
# Git フックの有効化（初回のみ）
sh scripts/setup-hooks.sh
```

## プロジェクト構成

```
recipe_search_app/
├── lib/
│   ├── main.dart                  # エントリポイント（ProviderScope / MaterialApp）
│   ├── models/                    # ドメイン・状態モデル（手書き）
│   │   ├── recipe.dart            # Recipe / RecipeStep / RecipeComment / NutritionInfo
│   │   └── filter_state.dart      # FilterState / IngredientFilter / 各種 enum
│   ├── database/                  # drift によるローカル永続化
│   │   ├── database.dart          # FavoriteRecipes テーブル / AppDatabase
│   │   └── database.g.dart        # 生成物（コミット対象）
│   ├── repositories/
│   │   └── recipe_repository.dart # サンプルレシピ + お気に入り DB の集約窓口
│   ├── viewmodels/                # Riverpod Provider 群
│   │   ├── providers.dart         # @riverpod 定義
│   │   └── providers.g.dart       # 生成物（コミット対象）
│   ├── views/                     # 画面 Widget（HookConsumerWidget）
│   │   ├── main_navigation_screen.dart
│   │   ├── recipe_list_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── calendar_screen.dart
│   │   └── recipe_detail_screen.dart
│   └── widgets/                   # 再利用 UI 部品
│       ├── recipe_card.dart
│       ├── filter_section.dart
│       ├── advanced_filter_sheet.dart
│       └── nutrition_chart.dart
├── test/
│   └── models/                    # モデルの単体テスト
│       ├── filter_state_test.dart
│       └── recipe_test.dart
├── .github/workflows/ci.yml       # GitHub Actions（品質ゲート）
├── .githooks/pre-commit           # コミット前に dart format を実行するフック
├── scripts/                       # setup-hooks.sh / claude_format_hook.sh
├── .claude/settings.json          # Claude Code の権限・フック設定
├── .mise.toml                     # Flutter バージョン固定
├── android/ ios/                  # モバイル向けネイティブプロジェクト
├── linux/ macos/ windows/ web/    # Flutter 既定のひな形（本アプリでは未対応・動作確認なし）
├── analysis_options.yaml          # flutter_lints ベースの Lint 設定
└── pubspec.yaml
```

> `android/`と`ios/`が主なターゲットです。`linux/` `macos/` `windows/` `web/`は`flutter create`が生成した既定のひな形がコミットされているだけで、デスクトップ／Web向けの実装・動作確認は行っていません。

## アーキテクチャ

MVVM + Repositoryパターンを採用し、状態管理は`@riverpod`でコード生成したProvider群で行います。レイヤー構成図・Provider依存関係図・ER図・画面遷移図（いずれもMermaid）は[architecture_guidance.md](./architecture_guidance.md)を参照してください。

```mermaid
graph LR
  UI[View<br/>HookConsumerWidget] --> VM[Riverpod Provider] --> Repo[RecipeRepository]
  Repo --> Sample[サンプルレシピ]
  Repo --> DB[(drift / SQLite)]
```

## テスト

```bash
# 全テスト実行
flutter test
# カバレッジ出力（coverage/lcov.info を生成）
flutter test --coverage
```

テストは役割ごとにディレクトリを分けています（計 11 ファイル / 62 ケース）。

| ディレクトリ | 内容 |
|--------------|------|
| `test/models/` | `applyFilters`（複合フィルタ・カバレッジ 100%）、`FilterState` / `Recipe` の単体テスト |
| `test/repositories/` | `RecipeRepository` の検索系（`searchRecipes` / `getRecipesByCategory` / `getRecipeById`）をインメモリ drift で検証（100%） |
| `test/viewmodels/` | Provider のテスト（`FavoriteRecipes` の永続化、`AppDatabase` が dispose 時に close されること） |
| `test/migration/` | 旧バージョンで作成した DB を開ける互換性テスト（drift/sqlite3 更新時の回帰防止） |
| `test/views/` `test/widgets/` | レシピ一覧の検索・絞り込み、詳細フィルタシート、レシピ詳細、栄養グラフの Widget テスト |
| `test/support/` | `NetworkImage` を差し替えるテストヘルパー（非テスト） |

中核の絞り込み・検索ロジック（`applyFilters` / `RecipeRepository`）はカバレッジ 100%です。

## 品質ゲート（CI / Gitフック）

| 仕組み | 内容 |
|--------|------|
| GitHub Actions（`.github/workflows/ci.yml`） | `main`へのpushとPRで、`flutter pub get` → フォーマットチェック → `flutter analyze` → 生成コードのコミット漏れ検出（build_runner + `git status`）→ `flutter test --coverage`を実行。カバレッジはJob Summaryに出力。 |
| Gitフック（`.githooks/pre-commit`） | コミット時にステージ済みの`.dart`（`*.g.dart`を除く）へ`dart format`を自動適用。`sh scripts/setup-hooks.sh`で有効化。 |
| Claude Code設定（`.claude/settings.json`） | flutter / dart / gitの読み取り系コマンドとbuild_runnerを許可、`git push --force`や`rm -rf`を禁止。Edit/Write後に変更`.dart`を自動整形するPostToolUseフックを設定。 |

CIと同じチェックはローカルでも実行できます。

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs && git status --porcelain
flutter test --coverage
```

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| `*.g.dart`が見つからない／Providerが未定義エラー | `dart run build_runner build --delete-conflicting-outputs`を実行 |
| 生成物の競合エラー | `--delete-conflicting-outputs`を付けて再生成（上記コマンド） |
| CIの「Format check」で失敗する | ローカルで`dart format .`を実行して差分をコミット（フック有効化で自動化できる） |
| CIの「Verify generated code is committed」で失敗する | build_runnerを実行し、生成された`*.g.dart`をコミット |
| pre-commitフックが動かない | `sh scripts/setup-hooks.sh`を実行して`core.hooksPath`を設定したか確認 |
| お気に入りの挙動がおかしい／DBを初期化したい | 端末のアプリデータを削除するとドキュメントディレクトリの`recipes.sqlite`が消え、初期状態に戻る |
| 依存解決に失敗する | Flutter / Dartのバージョンが[前提条件](#前提条件)を満たしているか`flutter doctor`で確認 |

## Claude CodeのSkill / Subagent

本リポジトリには開発を補助するClaude CodeのSkill（`/codegen` `/add-feature` `/drift-schema-change` `/add-provider-test` `/doc-sync`）とSubagent（`code-reviewer` / `test-writer` / `impact-analyzer`）を同梱しています。一覧・呼び出し例・連携フローは[skill_guidance.md](./skill_guidance.md)を参照してください。

## ドキュメント

- [CLAUDE.md](./CLAUDE.md) — AIエージェント／開発者向けの作業ガイド（技術スタック・コマンド・守るべきルール・コード生成トリガー）
- [architecture_guidance.md](./architecture_guidance.md) — 詳細なアーキテクチャ解説（レイヤー構成・Provider依存・ER図・画面遷移図）
- [skill_guidance.md](./skill_guidance.md) — Claude CodeのSkill / Subagent一覧と連携フロー
