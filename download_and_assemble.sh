#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$REPO_ROOT/manifest/programs.json"
PORTABLE_DIR="$REPO_ROOT/portable"
BUILD_DIR="$REPO_ROOT/build"
CHECKSUMS="$REPO_ROOT/checksums.txt"

# Requirements: curl or wget, jq, sha256sum or shasum
cmd_exists() { command -v "$1" >/dev/null 2>&1; }
DL_TOOL=""
if cmd_exists curl; then DL_TOOL="curl"; elif cmd_exists wget; then DL_TOOL="wget"; else
  echo "需要 curl 或 wget，请安装后重试。" >&2
  exit 1
fi
if ! cmd_exists jq; then
  echo "需要 jq，请安装后重试。" >&2
  exit 1
fi

mkdir -p "$PORTABLE_DIR" "$BUILD_DIR"

echo "读取 manifest: $MANIFEST"
programs=$(jq -c '.programs[]' "$MANIFEST")

timestamp() { date -u +"%Y%m%dT%H%M%SZ"; }

download_file() {
  local url="$1"; local out="$2"
  echo "下载：$url -> $out"
  if [ "$DL_TOOL" = "curl" ]; then
    curl -L --fail --retry 3 -o "$out" "$url"
  else
    wget -O "$out" "$url"
  fi
}

get_hash_cmd() {
  if command -v sha256sum >/dev/null 2>&1; then
    echo "sha256sum"
  else
    echo "shasum -a 256"
  fi
}

verify_checksum() {
  local file="$1" expected="$2"
  if [ -z "$expected" ]; then
    echo "未提供预期哈希，跳过校验： $file"
    return 0
  fi
  local actual
  actual=\$($(get_hash_cmd) "$file" | awk '{print $1}')
  if [ "$actual" = "$expected" ]; then
    echo "校验通过：$file"
    return 0
  else
    echo "校验失败：$file"
    echo "  期望: $expected"
    echo "  实际: $actual"
    return 2
  fi
}

echo "开始处理程序..."
while IFS= read -r p; do
  id=\