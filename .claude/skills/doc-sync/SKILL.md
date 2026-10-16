---
name: doc-sync
description: |
  コードと CLAUDE.md / README.md / architecture_guidance.md の乖離を検出・修正する。
  context: fork で独立実行し、本会話のコンテキストを汚さない。
  --check は検出のみ（変更しない）、--fix は修正まで行う。
  「ドキュメントが古い」「doc を同期して」「README を最新にして」
  「アーキテクチャドキュメントを更新して」などのリクエストで使用する。
argument-hint: "[--check|--fix]"
context: fork
allowed-tools:
  - Read
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# doc-sync — ドキュメント整合チェック

ソースの実態とドキュメント記述のズレを突き合わせる。既定は `--check`（検出のみ）。
`--fix` のときだけ Edit でドキュメントを更新する。

## 照合する対象（コード → ドキュメント）

| 観点 | 情報源（コード） | 反映先（ドキュメント） |
|------|------------------|------------------------|
| Provider 一覧・種別 | `lib/viewmodels/providers.dart` の `@riverpod` | architecture_guidance.md 第 3 章、依存図 |
| drift テーブル / `schemaVersion` | `lib/database/database.dart` | architecture_guidance.md 第 4 章（ER 図）、CLAUDE.md のルール |
| 画面・遷移 | `lib/views/` と `Navigator.push` | architecture_guidance.md 第 5 章 |
| 技術スタック / バージョン | `pubspec.yaml` | CLAUDE.md 技術スタック表、README 前提条件 |
| スキル一覧 | `.claude/skills/*/SKILL.md` | skill_guidance.md の表、README/CLAUDE のリンク |
| テスト構成 | `test/` | README テスト節 |

## 手順

1. 上表の情報源を読み、現在の事実を列挙する（例: Provider 名の集合、テーブルのカラム、schemaVersion、依存バージョン、スキル数）。
2. 対応するドキュメント記述を読み、差分（追加・削除・名称変更・数の不一致・バージョン相違）を分類する。
3. `--check`: 差分を一覧で報告して終了（ファイルは変更しない）。
4. `--fix`: 事実に合わせてドキュメントを Edit で更新する。Mermaid 図のノードやラベルもコードに合わせる。
5. `--fix` 実行後は整合を確認する。
   ```bash
   git --no-pager diff --stat -- '*.md'
   ```

## 完了条件

- `--check`: 検出した差分（なければ「乖離なし」）を明示して終了。
- `--fix`: 変更したドキュメントがコードの事実と一致し、Mermaid 構文が壊れていない。

## 失敗時の対処

| 症状 | 対処 |
|------|------|
| 情報源が多く差分が曖昧 | 観点を 1 つずつ（例: Provider だけ）に絞って照合する。 |
| Mermaid 図の崩れ | ノード ID・ラベル・エッジ記法を既存図に合わせる。括弧はクォート内のみで使う。 |
| 変更量が大きい | まず `--check` で全差分を提示し、ユーザーに適用範囲を確認してから `--fix`。 |

> 注: `context: fork` のため、調査の中間出力は本会話に残らない。最終結果（差分一覧 or 修正サマリー）だけを返す。
