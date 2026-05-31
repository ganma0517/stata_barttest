#!/bin/bash
# 雙擊即可：清除殘留 lock → commit 所有變更 → 推上 GitHub
# 若 push 認證失敗，請先在下一行填入有效 token（取代 PUT_TOKEN_HERE），存檔後再雙擊。
TOKEN="PUT_TOKEN_HERE"

cd "$(dirname "$0")" || exit 1
echo "==> 專案資料夾: $(pwd)"

echo "==> 清除殘留 git lock"
rm -f .git/index.lock .git/HEAD.lock .git/config.lock .git/refs/remotes/origin/main.lock 2>/dev/null

echo "==> 設定身分（首次需要）"
git config user.email "jay8956047@gmail.com"
git config user.name "Wen-Cheng Lin"

echo "==> 加入並提交所有變更"
git add -A
git commit -m "update barttest" || echo "（沒有新變更可提交，或已提交）"

# 若有填 token，重設帶 token 的 remote
if [ "$TOKEN" != "PUT_TOKEN_HERE" ] && [ -n "$TOKEN" ]; then
  echo "==> 使用提供的 token 設定 remote"
  git remote set-url origin "https://ganma0517:${TOKEN}@github.com/ganma0517/stata_barttest.git"
fi

echo "==> 推送到 GitHub"
git push origin main

echo ""
echo "==> 完成。請查看上方是否出現 'main -> main'（成功）。"
echo "    若出現 Authentication failed，請編輯本檔，把 PUT_TOKEN_HERE 換成有效 token，再雙擊一次。"
echo ""
read -n 1 -s -r -p "按任意鍵關閉視窗..."
