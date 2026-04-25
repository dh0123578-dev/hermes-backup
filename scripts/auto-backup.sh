#!/bin/bash
# ==========================================
# Hermes 自动备份脚本
# 备份: 配置、记忆、会话、技能、状态
# ==========================================
set -e

BACKUP_DIR="$HOME/.hermes"
cd "$BACKUP_DIR"

# 确保是 Git 仓库
if [ ! -d ".git" ]; then
    echo "❌ 不是 Git 仓库，跳过备份"
    exit 1
fi

# 检测是否有变更
CHANGED=$(git status --porcelain 2>/dev/null | head -20)
if [ -z "$CHANGED" ]; then
    echo "✅ 无变更，跳过备份"
    exit 0
fi

# 添加所有追踪的备份数据
git add -A config.yaml auth.json .env memories/ sessions/ skills/ cron/ state.db .gitignore

# 生成提交信息
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
FILES=$(git diff --cached --name-only | wc -l)

# 提交
git commit -m "📦 自动备份 $TIMESTAMP ($FILES 个文件变更)"

# 如果有远程仓库则推送，没有就跳过
REMOTE=$(git remote 2>/dev/null)
if [ -n "$REMOTE" ]; then
    git pull --rebase --no-edit 2>/dev/null || true
    git push 2>/dev/null && echo "🚀 已推送到远程仓库" || echo "⚠️ 推送失败（可能是网络问题）"
else
    echo "📌 本地备份完成（未配置远程仓库）"
fi

echo "✅ 备份完成"
