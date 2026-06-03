#!/bin/bash
# ================================================
# mario_english_practice.html を GitHub にPushするスクリプト
# ================================================

TOKEN="${GITHUB_TOKEN:-}"  # 環境変数から読む。使う時は `export GITHUB_TOKEN=ghp_xxx` してから実行
REPO_NAME="mario-english-practice"
HTML_FILE="mario_english_practice.html"

# カレントディレクトリをスクリプトの場所に変更
cd "$(dirname "$0")"

echo "🔍 GitHubユーザー名を取得中..."
USERNAME=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | python3 -c "import json,sys; print(json.load(sys.stdin)['login'])")

if [ -z "$USERNAME" ]; then
  echo "❌ GitHubトークンが無効か、ユーザー名を取得できませんでした。"
  exit 1
fi

echo "✅ ユーザー名: $USERNAME"

echo ""
echo "📦 GitHubリポジトリ '$REPO_NAME' を作成中..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$REPO_NAME\", \"description\": \"Mario English Practice App\", \"private\": false}" \
  https://api.github.com/user/repos)

REPO_URL=$(echo $RESPONSE | python3 -c "import json,sys; print(json.load(sys.stdin).get('clone_url',''))")

if [ -z "$REPO_URL" ]; then
  echo "❌ リポジトリの作成に失敗しました。すでに同名のリポジトリが存在する可能性があります。"
  echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('message',''))"
  exit 1
fi

echo "✅ リポジトリ作成完了: https://github.com/$USERNAME/$REPO_NAME"

echo ""
echo "📁 Gitリポジトリを初期化中..."
WORK_DIR=$(mktemp -d)
cp "$HTML_FILE" "$WORK_DIR/index.html"
cd "$WORK_DIR"

git init
git config user.email "dorakengo.14@gmail.com"
git config user.name "$USERNAME"
git add index.html
git commit -m "Initial commit: Add mario_english_practice.html"

echo ""
echo "🚀 GitHubにPush中..."
git remote add origin "https://$USERNAME:$TOKEN@github.com/$USERNAME/$REPO_NAME.git"
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 Push完了！"
  echo "👉 リポジトリURL: https://github.com/$USERNAME/$REPO_NAME"
else
  echo "❌ Pushに失敗しました。"
fi

# 後片付け
cd ~
rm -rf "$WORK_DIR"
