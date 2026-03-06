#!/bin/bash
# push-wiki.sh — 将 wiki/ 目录推送到 GitHub Wiki 仓库
#
# 使用前提：
#   1. 先在 GitHub 仓库页面点击 "Wiki" 标签
#   2. 点击 "Create the first page" 创建任意首页
#   3. 然后运行此脚本推送完整 Wiki
#
# 用法: bash push-wiki.sh

set -e

REPO_URL="https://github.com/zxk-git/openclaw-tutorial-auto.wiki.git"
WIKI_DIR="$(cd "$(dirname "$0")" && pwd)/wiki"
TEMP_DIR="/tmp/openclaw-wiki-push-$$"

if [ ! -d "$WIKI_DIR" ]; then
  echo "❌ wiki/ 目录不存在"
  exit 1
fi

echo "📥 克隆 Wiki 仓库..."
git clone "$REPO_URL" "$TEMP_DIR"

echo "📋 复制 Wiki 页面..."
cp "$WIKI_DIR"/*.md "$TEMP_DIR/"

cd "$TEMP_DIR"
git add -A
git commit -m "docs: 推送完整 Wiki (19 页)"

echo "🚀 推送到 GitHub..."
git push origin master

echo "✅ Wiki 推送完成！"
echo "🔗 https://github.com/zxk-git/openclaw-tutorial-auto/wiki"

# 清理
rm -rf "$TEMP_DIR"
