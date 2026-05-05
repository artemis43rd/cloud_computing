#!/usr/bin/env bash

YC_BIN="$HOME/yandex-cloud/bin/yc"

YC_TOKEN=$($YC_BIN iam create-token)
YC_CLOUD_ID=$($YC_BIN config get cloud-id)
YC_FOLDER_ID=$($YC_BIN config get folder-id)

jq -n \
  --arg token "$YC_TOKEN" \
  --arg cloud_id "$YC_CLOUD_ID" \
  --arg folder_id "$YC_FOLDER_ID" \
  '{"token": $token, "cloud_id": $cloud_id, "folder_id": $folder_id}'
