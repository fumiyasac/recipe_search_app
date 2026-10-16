#!/bin/sh
# Claude Code の PostToolUse フック。
# Edit / Write / MultiEdit の対象が .dart（生成物 *.g.dart は除外）なら dart format を実行する。
# フック情報は標準入力に JSON で渡される（tool_input.file_path を参照）。

input=$(cat)

# tool_input.file_path を抽出（jq があれば利用、なければ sed にフォールバック）
if command -v jq >/dev/null 2>&1; then
  file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
else
  file_path=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi

[ -z "$file_path" ] && exit 0

case "$file_path" in
  *.g.dart) exit 0 ;;       # 生成物は整形しない
  *.dart) ;;                # Dart ファイルのみ対象
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

dart format "$file_path" >/dev/null 2>&1 || true
exit 0
