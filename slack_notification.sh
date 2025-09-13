#!/bin/bash

# --- 設定 ---
# ログファイルのパス。実行ごとに一意なファイル名を作成します。
LOG_FILE="./command_log_$(date +%Y%m%d_%H%M%S).txt"
# 実行するコマンド。
COMMAND="gmt --version" # ここに実行したいコマンドを入力

# Slackのメッセージ通知用のWebhook URL。
WEBHOOK_URL="WEBHOOK URL"

# --- 実行 ---
echo "▶️ コマンド実行: \"$COMMAND\""

# コマンドの実行時間を計測
START_TIME=$(date +%s)
$COMMAND &>> "$LOG_FILE"
STATUS=$?
END_TIME=$(date +%s)

# 実行時間を計算
RUN_TIME=$((END_TIME - START_TIME))

echo "✅ コマンド実行が完了しました。ステータス: $STATUS"

# --- 終了ステータスに基づくメッセージ通知 ---
COMMAND_NAME=$(echo "$COMMAND" | awk '{print $1}')
if [ $STATUS -eq 0 ]; then
    MESSAGE_TEXT="✅ Command \`$COMMAND_NAME\` succeeded. Elapsed time: ${RUN_TIME} seconds."
else
    MESSAGE_TEXT="❌ Command \`$COMMAND_NAME\` failed with status $STATUS. Elapsed time: ${RUN_TIME} seconds."
fi

# Webhook経由でメッセージを送信します。
curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$MESSAGE_TEXT\"}" "$WEBHOOK_URL"

# ログファイルは不要なので削除
#rm "$LOG_FILE"

exit $STATUS