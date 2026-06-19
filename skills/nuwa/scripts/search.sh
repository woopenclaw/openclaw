#!/bin/bash
# 女娲调研用搜索+提取脚本
# 用法:
#   bash search.sh "查询词"                    → 搜索（返回 JSON）
#   bash search.sh "查询词" -n 10              → 指定结果数量
#   bash search.sh --extract "https://url"     → 提取网页正文
#   bash search.sh "查询词" --extract 3        → 搜索 + 提取前N个结果正文

set -euo pipefail

MODE="search"
QUERY=""
COUNT=10
EXTRACT_N=0
URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --extract)
      if [[ "${2:-}" =~ ^https?:// ]]; then
        MODE="extract"
        URL="$2"
        shift 2
      elif [[ "${2:-}" =~ ^[0-9]+$ ]]; then
        EXTRACT_N="$2"
        shift 2
      else
        MODE="extract"
        shift
      fi
      ;;
    -n)
      COUNT="$2"
      shift 2
      ;;
    *)
      QUERY="$1"
      shift
      ;;
  esac
done

# 确保依赖
python3 -c "import requests" 2>/dev/null || pip3 install -q requests --break-system-packages 2>/dev/null
python3 -c "import trafilatura" 2>/dev/null || pip3 install -q trafilatura --break-system-packages 2>/dev/null

# 优先用 Bing（DuckDuckGo 在当前网络被墙）
BING_SEARCH="$HOME/scripts/bing_search.py"
USE_BING=1

if [[ "$MODE" == "extract" && -n "$URL" ]]; then
  # 单 URL 提取正文
  python3 -c "
import trafilatura, json, sys
url = sys.argv[1]
downloaded = trafilatura.fetch_url(url)
text = trafilatura.extract(downloaded, include_links=True, include_comments=False) if downloaded else None
print(json.dumps({'url': url, 'content': text or '(提取失败)', 'length': len(text) if text else 0}, ensure_ascii=False, indent=2))
" "$URL"

elif [[ -n "$QUERY" ]]; then
  # 搜索（+ 可选提取）
  if [ "$USE_BING" = "1" ] && [ -f "$BING_SEARCH" ]; then
    # 使用 Bing 搜索（DuckDuckGo 被墙时自动降级）
    python3 "$BING_SEARCH" "$QUERY" -n "$COUNT" --json
    if [ "$EXTRACT_N" -gt 0 ] 2>/dev/null; then
      python3 "$BING_SEARCH" "$QUERY" -n "$COUNT" --extract "$EXTRACT_N" --json
    fi
  else
    # 使用 DuckDuckGo 搜索
    python3 -c "
from ddgs import DDGS
import trafilatura, json, sys

query = sys.argv[1]
count = int(sys.argv[2])
extract_n = int(sys.argv[3])

with DDGS() as d:
    results = list(d.text(query, max_results=count))

if extract_n > 0:
    for r in results[:extract_n]:
        try:
            downloaded = trafilatura.fetch_url(r['href'])
            r['full_content'] = trafilatura.extract(downloaded, include_links=True) if downloaded else '(提取失败)'
        except Exception as e:
            r['full_content'] = f'(提取失败: {e})'

print(json.dumps(results, ensure_ascii=False, indent=2))
" "$QUERY" "$COUNT" "$EXTRACT_N"
  fi

else
  echo '用法:'
  echo '  bash search.sh "查询词"                 → 搜索'
  echo '  bash search.sh "查询词" -n 10            → 指定数量'
  echo '  bash search.sh "查询词" --extract 3      → 搜索+提取前3个正文'
  echo '  bash search.sh --extract "https://..."   → 提取单个URL正文'
  exit 1
fi
