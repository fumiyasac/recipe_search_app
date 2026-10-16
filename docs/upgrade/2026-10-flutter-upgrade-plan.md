# Flutter / 依存パッケージ 更新計画（2026-10）

作成日: 2026-10-17 / ブランチ: `chore/upgrade-flutter-and-deps`

①〜③で整備した CI・Skill・Subagent を検証に活用し、**壊さずに上げる**ことを最優先とする。

## ベースライン（更新前）

| 項目 | 値 |
|------|----|
| Flutter | 3.47.5（stable, 2026-09-18） |
| Dart | 3.13.4 |
| `flutter analyze` | 0 件（No issues found!） |
| `flutter test` | 16/16 passed |
| カバレッジ | 44.7%（551/1234 行） |

> ベースラインでテストは全て通過しているため、更新作業に進む。

## Flutter SDK

| | 現行 | 目標 |
|--|------|------|
| Flutter | 3.47.5 | **3.47.7**（stable, 2026-10-08） |
| Dart | 3.13.4 | 3.13.x（3.47 系のまま） |

- リリースフィード（`releases_macos.json`）で確認した最新 stable は **3.47.7**。stable に 3.48 系は未リリース（3.48 は beta のみ）。
- 3.47.5 → 3.47.7 は**同一マイナー系のパッチ更新**で、フレームワークの破壊的変更はなし（バグ/セキュリティ修正のみ）。リスクは低い。
- 破壊的変更・非推奨 API: 3.47 系内のパッチのため該当なし。`dart fix --dry-run` は "Nothing to fix!"。
- **実行環境メモ**: 本マシンに `mise` は未インストールで、Flutter は **fvm**（`~/fvm/default`、3.47.5）管理。`mise install` は実行不可のため、`.mise.toml` と CI（`subosito/flutter-action` の `flutter-version`）の宣言ピンを 3.47.7 に更新し、**CI が実際に 3.47.7 で検証**する。ローカル検証は 3.47.5（パッチ等価）で実施。
- **ネイティブ scaffold ドリフト（既知・本PRでは据え置き）**: `flutter create` の最新テンプレートと比較すると、Android が repo 側で古い: AGP 8.11.1（テンプレート 9.1.0）、Kotlin 2.2.20（2.4.0）、Gradle 8.14（9.3.1）、`kotlin{}` DSL も旧形式。これは 3.47.7 パッチ更新に **必須ではなく**、AGP/Gradle/Kotlin のメジャー更新は破壊リスクが高いため本PRでは取り込まない。現行構成で `flutter build apk --debug` が通ることを Step 5 で確認し、ネイティブ更新は別途対応候補とする。iOS は Podfile/Deployment Target 13.0 で現行テンプレートと差異なし。

## 依存パッケージの区分

### A: 制約内で上がる（パッチ・マイナー）—`flutter pub upgrade <名前>` で一括

| パッケージ | 現行 | 目標 | 備考 |
|------------|------|------|------|
| flutter_riverpod | 3.1.0 | 3.4.3 | riverpod グループで同時に上げる |
| hooks_riverpod | 3.1.0 | 3.4.3 | 同上 |
| riverpod_annotation | 4.0.0 | 4.0.7 | 同上 |
| riverpod_generator (dev) | 4.0.0+1 | 4.0.9 | 同上。codegen 再実行必須 |
| path_provider | 2.1.5 | 2.1.6 | |
| uuid | 4.5.2 | 4.6.0 | |
| build_runner (dev) | 2.10.4 | 2.16.2 | |

riverpod 4 パッケージ + flutter_hooks の整合性: いずれも現行制約（riverpod 系 `^3`/`^4`、flutter_hooks `^0.21.3+1`）内で解決でき、マイナー更新のため破壊的変更なしと判断。実行時に analyze で非推奨を確認する。

> ⚠️ A の一括更新では **drift / sqlite3 系を巻き込まないよう、パッケージ名を明示して** `flutter pub upgrade` する（素の `flutter pub upgrade` だと transitive の `sqlite3` が 2.x→3.x に上がってしまうため。下記 C 参照）。

### B: pubspec.yaml 編集が必要（影響は小）—1 件ずつ

| パッケージ | 現行制約 | 目標 | 影響箇所 | 対応 |
|------------|----------|------|----------|------|
| cupertino_icons | ^1.0.8 | ^2.0.0 | アイコンフォント（アセットのみ） | メジャーだが実コードへの影響は想定なし。ビルドで確認 |
| fl_chart | ^0.69.0 | ^1.2.0 | `lib/widgets/nutrition_chart.dart` のみ | **影響小**: 当該コードは `PieChart`/`PieChartData`/`PieChartSectionData` のみ使用。1.0 で削除された `swapAnimationDuration/Curve`・`tooltipRoundedRadius` は**未使用**。bump 後にグラフ描画を目視確認 |
| table_calendar | ^3.0.9 | ^3.3.0 | `lib/views/calendar_screen.dart` のみ | 3.3.0 は `locale` 型が `dynamic`→`String?`。locale 未指定なら影響なし。要確認 |
| intl | ^0.19.0 | ^0.20.3 | **lib 内で未使用**（直接参照なし） | table_calendar 3.3.0 が `intl >=0.20.3` を要求するため連動して上げる。flutter_localizations は未使用のためピン留め競合なし |

> table_calendar と intl は **同時に** 上げる（table_calendar 3.3.0 の intl 下限制約のため）。

### C: 影響が大きい / 要判断 —慎重に、承認を仰ぐ

| パッケージ | 現行 | 「最新」 | 判断 |
|------------|------|----------|------|
| **sqlite3_flutter_libs** | 0.5.41 | **0.6.0+eol** | **上げない（据え置き）。** 0.6.0 は EOL リリースで「全コードを削除」し、`sqlite3` v3.x のネイティブ読み込みへ移行（＝本パッケージ廃止）を推奨するもの。これはパッケージ置き換え／アーキテクチャ変更に当たるため、本 PR では実施せず別途判断とする。制約 `^0.5.20` のまま 0.5.42 に留める |
| **sqlite3**（transitive） | 2.9.4 | 3.7.1 | drift を 2.35 系へ上げると transitive で 3.x へ移動し得る。DB の互換性検証（後述）を必須とする。検証が通らなければ drift ごと据え置き |
| **drift / drift_dev** | 2.30.0 | 2.35.2 / 2.35.1 | 制約内（`^2.16.0`）のマイナー更新だが、上記 sqlite3 と連動するため **C として独立ステップで検証**（A の一括には含めない） |

#### impact-analyzer による C 区分の利用箇所（読み取り専用調査の結果）

- **sqlite3_flutter_libs**: `lib/` に直接 import なし（drift のネイティブライブラリ供給用の runtime 依存）。実際の DB オープンは `lib/database/database.dart` の `_openConnection()` → `NativeDatabase(file)`。
- **sqlite3**: 直接 import なし（drift 経由の transitive）。
- **drift**: `lib/database/database.dart`（`AppDatabase` / `FavoriteRecipes` / `NativeDatabase` / `LazyDatabase`）、`lib/repositories/recipe_repository.dart`（`FavoriteRecipesCompanion` / `drift.Value`）、生成物 `database.g.dart`、`test/viewmodels/favorite_recipes_provider_test.dart`（`AppDatabase.forTesting` + `NativeDatabase.memory()`）。

## 実行方針（Step 2 以降）

1. **Flutter 3.47.7**（`.mise.toml` + `environment.sdk`）。`dart fix` 適用。codegen→format→analyze→test。
2. **A 一括**（riverpod 系・path_provider・uuid・build_runner をパッケージ名指定で upgrade）。drift/sqlite3 は巻き込まない。codegen→検証→コミット。
3. **B を 1 件ずつ**: cupertino_icons → (table_calendar + intl) → fl_chart。各々 pub get→（必要なら）コード修正→codegen→検証→コミット。
4. **drift（+ sqlite3 transitive）を独立ステップ**で上げ、以下の互換性検証を必ず実施:
   - main 状態で作成した DB ファイルを更新後アプリで開き、お気に入りデータが読めること。
   - `drift_dev schema dump` と、マイグレーション検証テスト（なければ test-writer で追加）。
   - 検証が通らなければ drift を据え置き、理由を記録。
5. **sqlite3_flutter_libs 0.6.0+eol への移行は本 PR では見送り**、既知の課題として記録（別 PR でチーム判断）。

## 影響の大きい手動確認ポイント（見た目が変わり得る箇所）

- カレンダー表示（`calendar_screen.dart` / table_calendar）
- 栄養バランスの円グラフ（`nutrition_chart.dart` / fl_chart 1.x）
- Cupertino アイコン表示（cupertino_icons 2.x）

## 実施結果

### 最終バージョン（更新前 → 更新後）

| パッケージ / SDK | 前 | 後 |
|------------------|----|----|
| Flutter（ピン） | 3.47.5 | 3.47.7（ローカル検証は 3.47.5、CI は 3.47.7） |
| flutter_riverpod / hooks_riverpod / riverpod | 3.1.0 | 3.4.3 |
| riverpod_annotation | 4.0.0 | 4.0.7 |
| riverpod_generator (dev) | 4.0.0+1 | 4.0.9 |
| drift | 2.30.0 | 2.35.2 |
| drift_dev (dev) | 2.30.0 | 2.35.1 |
| sqlite3（transitive） | 2.9.4 | 3.7.1 |
| sqlite3_flutter_libs | 0.5.41 | 0.5.42 |
| analyzer（transitive） | 8.4.1 | 14.5.0 |
| source_gen / build_runner (dev) | 4.1.1 / 2.10.4 | 4.3.1 / 2.16.2 |
| cupertino_icons | 1.0.8 | 2.0.0 |
| table_calendar | 3.1.3 | 3.3.0 |
| fl_chart | 0.69.2 | 1.2.0 |
| intl | 0.19.0 | 0.20.3 |
| path_provider / uuid | 2.1.5 / 4.5.2 | 2.1.6 / 4.6.0 |

### ベースライン比較

| 指標 | 前 | 後 |
|------|----|----|
| `flutter analyze` | 0 件 | 0 件（No issues found!） |
| `flutter test` | 16 passed | 17 passed（DB 互換テストを追加） |
| カバレッジ | 44.7%（551/1234） | 44.5%（551/1237、生成コード行数差。実質維持） |
| `flutter build apk --debug` | — | 成功 |
| `flutter build ios --no-codesign --debug` | — | 成功 |

### drift 互換性検証

- 更新前（drift 2.30 / sqlite3 2.x）に作成した DB フィクスチャを更新後（drift 2.35 / sqlite3 3.7.1）で開き、データが読めることを `test/migration/legacy_db_compat_test.dart` で確認。
- `drift_dev schema dump` で `drift_schemas/drift_schema_v1.json` を記録。schemaVersion は 1 のまま（スキーマ変更なし）。

### 見送ったパッケージ・変更とその理由

- **sqlite3_flutter_libs 0.6.0+eol**: EOL（全コード削除）で、`sqlite3` v3.x のネイティブ読み込みへの移行＝本パッケージ廃止を促すもの。アーキテクチャ変更に当たるため本 PR では見送り、0.5.42（非 EOL 系の最新）に留めた。別 PR でチーム判断。
- **Android ネイティブツールチェーン**（AGP 8.11.1→9.x、Gradle 8.14→9.x、Kotlin 2.2.20→2.3+）: `flutter build apk` は成功するが「将来サポート打ち切り」警告あり。本 PR の対象外（別途モダナイズ PR 推奨）。
- **iOS プロジェクト移行**（最小 iOS 13→15、UIScene ライフサイクル移行、Swift Package Manager 統合）: `flutter build ios` 実行時に新しい Flutter ツールが自動適用したが、デバイス検証を伴う大きな変更のため本 PR からは revert（コミットに含めない）。別 PR で対応推奨。

### 既知の課題

- 上記ネイティブ scaffold ドリフト（Android/iOS）は、いずれ Flutter 側のサポート打ち切りで必須対応になる。
- `environment.sdk` は `^3.10.4` のまま（Dart 3.13.x を満たすため変更不要）。

### 手動確認チェックリスト（見た目が変わり得る箇所）

- [ ] カレンダー画面（table_calendar 3.3.0）: 月表示・日付選択・選択中スタイル・ヘッダー
- [ ] 栄養バランスの円グラフ（fl_chart 1.2.0）: PieChart の描画、割合ラベル（%）、セクション色、レスポンシブ（縦/横レイアウト）
- [ ] お気に入りの追加・削除と再起動後の永続化（drift 2.35 / sqlite3 3.x）
- [ ] アプリ全体の起動と一覧・絞り込み・詳細遷移（riverpod 3.4.3）
