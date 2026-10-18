# スクリーンショット / デモ GIF 撮影ガイド

README に掲載する画像の撮影手順をまとめます。
本リポジトリ同梱の静止画（`*.png`）は Android エミュレータ（API 36 / 1080x2424）で撮影済みです。
**デモ GIF（`demo.gif`）は `ffmpeg` が必要なため未同梱**です。下記「デモ GIF」の手順で生成して配置してください。

## 前提

- iOS: シミュレータを起動（`open -a Simulator`）。`booted` は起動中のデバイスを指す。
- Android: エミュレータを起動し、`adb devices` で接続を確認（例: `emulator-5554`）。
- デモ GIF の変換に `ffmpeg`（`brew install ffmpeg`）。

アプリを起動しておく:

```bash
flutter run            # もしくは下記でインストール＋起動
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell monkey -p com.example.recipe_search_app -c android.intent.category.LAUNCHER 1
```

## 静止画スクリーンショット

| 画面 | 到達方法 | ファイル名 |
|------|----------|-----------|
| ホーム（一覧・検索） | 起動直後のホームタブ | `android_home.png` / `ios_home.png` |
| 詳細フィルタシート | ホームの「詳細フィルタ」ボタンをタップ | `filter_sheet.png` |
| レシピ詳細 | ホームでレシピカードをタップ | `detail.png` |
| 栄養グラフ（PFC） | 詳細画面を下にスクロールし「栄養バランス」を表示 | `nutrition.png` |
| カレンダー | 下部ナビの「カレンダー」をタップ | `calendar.png` |

撮影コマンド:

```bash
# iOS（起動中のシミュレータ）
xcrun simctl io booted screenshot docs/screenshots/<ファイル名>

# Android
adb exec-out screencap -p > docs/screenshots/<ファイル名>
```

Android を自動操作で遷移させる場合（座標は 1080x2424 の例。端末に合わせて調整）:

```bash
adb shell input tap 540 760     # 「詳細フィルタ」を開く
adb shell input keyevent 4      # 戻る（シートを閉じる）
adb shell input tap 284 1100    # 先頭のレシピカードを開く
adb shell input swipe 540 1800 540 850 300  # 詳細を下にスクロール
adb shell input tap 898 2260    # 下部ナビ「カレンダー」
```

## デモ GIF（検索 → フィルタ適用 → 詳細表示）

「検索バーに入力 → 詳細フィルタで条件を適用 → レシピカードをタップして詳細を開く」までを
10 秒前後で操作しながら録画し、幅 320px・5MB 以内の GIF に変換します。保存先は
`docs/screenshots/demo.gif`。

### iOS

```bash
# 録画開始（Ctrl-C で停止）。停止までの操作を手動で行う
xcrun simctl io booted recordVideo --codec h264 docs/screenshots/demo.mov
# 変換（10秒・幅320px・15fps）
ffmpeg -i docs/screenshots/demo.mov -t 10 -vf "fps=15,scale=320:-1:flags=lanczos" \
  -loop 0 docs/screenshots/demo.gif
rm docs/screenshots/demo.mov
```

### Android

```bash
# 録画（最大 time-limit 秒。別ターミナルで操作）
adb shell screenrecord --time-limit 12 --size 540x1212 /sdcard/demo.mp4
adb pull /sdcard/demo.mp4 docs/screenshots/demo.mp4
# 変換
ffmpeg -i docs/screenshots/demo.mp4 -t 10 -vf "fps=15,scale=320:-1:flags=lanczos" \
  -loop 0 docs/screenshots/demo.gif
rm docs/screenshots/demo.mp4
```

### サイズを 5MB 以内に収めるコツ

- `fps` を 10〜15 に下げる。
- `scale` の幅を 320 以下にする。
- 尺（`-t`）を短くする。
- パレット最適化: `ffmpeg -i in.mp4 -vf "fps=12,scale=320:-1:flags=lanczos,palettegen" palette.png` →
  `ffmpeg -i in.mp4 -i palette.png -lavfi "fps=12,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" -t 10 demo.gif`

## Hero 遷移のデモ（修正後）

一覧 → 詳細 の Hero 遷移をスロー再生で録画する手順。`timeDilation` を上げてゆっくり再生し、
修正後の「画像だけが滑らかに飛び、情報カードが後からフェードイン・角丸が補間される」様子を見せる。

1. スロー再生: `lib/main.dart` の `runApp` 前に一時的に以下を追加（撮影後は戻す）。
   ```dart
   import 'package:flutter/scheduler.dart';
   // ...
   timeDilation = 6.0; // 6倍スロー
   ```
2. iOS シミュレータで録画して GIF 化（`ffmpeg` が必要）。
   ```bash
   xcrun simctl io booted recordVideo --codec h264 docs/screenshots/hero_demo.mov
   # 一覧でレシピをタップ → 詳細へ → 戻る、を実演してから Ctrl-C
   ffmpeg -i docs/screenshots/hero_demo.mov -t 10 -vf "fps=15,scale=320:-1:flags=lanczos" \
     -loop 0 docs/screenshots/hero_demo.gif
   rm docs/screenshots/hero_demo.mov
   ```
3. README の該当箇所に `docs/screenshots/hero_demo.gif` を掲載する。

> 本 PR の環境には `ffmpeg` が無いため GIF は未同梱。上記手順で生成すると README に表示される。

## ゴールデンテストの運用方針

- Hero 遷移のゴールデン（`test/golden/`）は **macOS（ローカル）でのみ生成・比較**する。
  CI は ubuntu で動作し、フォントのアンチエイリアス差で厳密一致しないため、テスト側で
  `skip: !Platform.isMacOS` により CI では skip する。
- 生成: `flutter test --update-goldens --tags golden`
- 比較: `flutter test --tags golden`（macOS）
- テキストは flutter_test の既定フォント（字形が矩形）で描画されるため、遷移中の
  レイアウト崩れ（情報カードの押しつぶし）や黄色下線の有無を安定して検出できる。
