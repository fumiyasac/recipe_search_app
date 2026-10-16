#!/bin/sh
# Git フックを有効化する。リポジトリをクローンした後に一度だけ実行すればよい。
#   sh scripts/setup-hooks.sh
set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# .githooks をフックパスに設定
git config core.hooksPath .githooks

# フックに実行権限を付与
chmod +x .githooks/* 2>/dev/null || true

echo "core.hooksPath を .githooks に設定しました。"
echo "以後のコミットで pre-commit フック（dart format）が実行されます。"
