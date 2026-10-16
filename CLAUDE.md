# CLAUDE.md

このファイルは Claude Code（および他の AI エージェント）が本リポジトリで作業する際のガイドです。詳細な設計情報は [architecture_guidance.md](./architecture_guidance.md) を参照してください。

## プロジェクト概要

レシピを検索・絞り込み・お気に入り登録し、カレンダーや栄養バランスで楽しむ Flutter 製のモバイルアプリです。レシピのマスタデータはアプリ内にハードコードされており、お気に入りのみ drift（SQLite）でローカル永続化します。

## 技術スタック

| 分類 | 使用技術 | バージョン（pubspec.yaml） |
|------|----------|---------------------------|
| SDK | Flutter / Dart | Flutter 3.47.5 / Dart 3.13.x（`environment.sdk: ^3.10.4`） |
| 状態管理 | flutter_riverpod | ^3.1.0 |
| 状態管理（コード生成） | riverpod_annotation / riverpod_generator | ^4.0.0 / ^4.0.0+1 |
| 状態管理（Hooks 連携） | hooks_riverpod / flutter_hooks | ^3.1.0 / ^0.21.3+1 |
| ローカル DB | drift / drift_dev | ^2.16.0 |
| SQLite ランタイム | sqlite3_flutter_libs | ^0.5.20 |
| パス解決 | path_provider / path | ^2.1.2 / ^1.9.0 |
| カレンダー UI | table_calendar | ^3.0.9 |
| グラフ UI | fl_chart | ^0.69.0 |
| ユーティリティ | intl / uuid | ^0.19.0 / ^4.3.3 |
| Lint | flutter_lints | ^6.0.0 |
| コード生成基盤 | build_runner | ^2.4.8 |

## セットアップ

```bash
# ツールバージョンの導入（mise 利用時。.mise.toml で Flutter 3.47.5 を固定）
mise install
# Git フックの有効化（初回のみ。コミット時に dart format を自動実行）
sh scripts/setup-hooks.sh
# 依存解決 → コード生成
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## よく使うコマンド

```bash
# 依存解決
flutter pub get

# コード生成（@riverpod / drift の *.g.dart を再生成）
dart run build_runner build --delete-conflicting-outputs
# 監視モードで生成し続ける場合
dart run build_runner watch --delete-conflicting-outputs

# 静的解析
flutter analyze

# フォーマット（チェックのみ／書き込み。CI は全体を対象にする）
dart format --output=none --set-exit-if-changed .
dart format .

# テスト
flutter test
# カバレッジ出力（coverage/lcov.info を生成）
flutter test --coverage

# 実行
flutter run
```

> 品質ゲート: `main` への push と PR で GitHub Actions（`.github/workflows/ci.yml`）がフォーマット・解析・生成物のコミット漏れ検出・テストを実行する。ローカルでも上記コマンドで同じチェックを再現できる。詳細は [README.md](./README.md) の「品質ゲート（CI / Git フック）」を参照。

## アーキテクチャの要点

MVVM + Repository パターンを `lib/` 配下のレイヤーフォルダで表現しています。

- **models (`lib/models/`)** — 手書きの素の Dart クラス（freezed / json_serializable は未使用）。`Recipe` などのドメインモデルと `FilterState` などの状態モデルを持つ。
- **database (`lib/database/`)** — drift の `AppDatabase` と `FavoriteRecipes` テーブルを定義。お気に入りの SQLite 永続化を担当。
- **repositories (`lib/repositories/`)** — `RecipeRepository` がレシピのサンプルデータ（ハードコード）とお気に入り DB をまとめ、上位層に単一の窓口を提供。
- **viewmodels (`lib/viewmodels/`)** — `@riverpod` で生成する Provider / Notifier / AsyncNotifier 群を `providers.dart` に集約。
- **views (`lib/views/`)** — 画面単位の Widget（`HookConsumerWidget`）。
- **widgets (`lib/widgets/`)** — 画面をまたいで再利用する UI 部品。

データの流れは `View → Provider(viewmodels) → Repository → Database / サンプルデータ` の一方向です。詳細な依存図・データフロー図は [architecture_guidance.md](./architecture_guidance.md) を参照してください。

## 守るべきルール（Do / Don't）

### Do

- **drift のテーブルを変更したら、必ず `AppDatabase.schemaVersion` を上げ、`MigrationStrategy`（`onUpgrade`）を実装する。** 現状 `schemaVersion = 1` でマイグレーション未定義のため、スキーマ変更は既存端末のデータ破損に直結する。
- Provider / Notifier を追加・変更したら `dart run build_runner build --delete-conflicting-outputs` を実行し、生成された `*.g.dart` を**同じコミットに含める**。
- 新しい画面・部品は `View = HookConsumerWidget` の既存慣習に合わせる。副作用・ローカル状態は `flutter_hooks`（`useState` / `useTextEditingController` 等）で扱う。
- ファイル名は `snake_case`、クラス名は `PascalCase`。ファイルは責務に応じたレイヤーフォルダ（models / database / repositories / viewmodels / views / widgets）に配置する。
- DB アクセスは `RecipeRepository` 経由に統一する（View / Provider から `AppDatabase` を直接叩かない）。

### Don't

- **`*.g.dart`（`database.g.dart` / `providers.g.dart`）を手で編集しない。** これらは生成物であり、コミット対象として追跡されている。変更はソース側（`@riverpod` / `Table` 定義）に対して行い、再生成する。
- レシピの絞り込みロジックを View に直接書かない。`FilteredRecipes` / `RecipeFilterState` Provider を使う。
- `pubspec.yaml` のバージョン制約を無断で大きく変更しない（riverpod 3 系・riverpod_generator 4 系の組み合わせに依存）。

## コード生成が必要になるトリガー

以下の変更を行った場合は `dart run build_runner build --delete-conflicting-outputs` を実行し、生成ファイルをコミットすること。

| 変更内容 | 再生成されるファイル |
|----------|---------------------|
| `@riverpod` Provider / Notifier / AsyncNotifier の追加・変更・削除（`lib/viewmodels/providers.dart`） | `lib/viewmodels/providers.g.dart` |
| drift の `Table` 定義や `@DriftDatabase` の変更（`lib/database/database.dart`） | `lib/database/database.g.dart` |
| family Provider の引数シグネチャ変更 | `lib/viewmodels/providers.g.dart` |

> 補足: 本リポジトリは `*.g.dart` を Git 管理対象に含める方針です（`.gitignore` で除外していません）。生成忘れ・コミット忘れがあると CI やレビューで差分が出ます。
