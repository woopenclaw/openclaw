#!/bin/bash
# 自动化工作流引擎
# 用法: ./workflow.sh <workflow_name> [参数]

SCRIPTS_DIR="/home/administrator/.openclaw/workspace/scripts"
CONTROL="$SCRIPTS_DIR/computer_control.sh"

# 工作流：给 Hermes 和 Codex 同时发消息
workflow_broadcast() {
    local MSG="$1"
    if [ -z "$MSG" ]; then
        echo "Usage: $0 broadcast <message>"
        exit 1
    fi
    
    echo "=== Broadcasting to Hermes and Codex ==="
    echo "Message: $MSG"
    echo ""
    
    echo "1. Sending to Hermes..."
    $CONTROL hermes send "$MSG"
    echo ""
    
    echo "2. Sending to Codex..."
    $CONTROL codex send "$MSG"
    echo ""
    
    echo "=== Broadcast complete ==="
}

# 工作流：查找并打开应用
workflow_open_app() {
    local APP_NAME="$1"
    if [ -z "$APP_NAME" ]; then
        echo "Usage: $0 open_app <app_name>"
        exit 1
    fi
    
    echo "=== Finding and opening: $APP_NAME ==="
    
    # 1. 搜索应用
    echo "1. Searching for $APP_NAME..."
    $CONTROL app find "$APP_NAME"
    echo ""
    
    # 2. 尝试聚焦窗口
    echo "2. Trying to focus window..."
    $CONTROL window focus "$APP_NAME"
    echo ""
    
    # 3. 截图确认
    echo "3. Taking screenshot..."
    $CONTROL screenshot "C:\Temp\after_open_${APP_NAME}.png"
    echo ""
    
    echo "=== Open app complete ==="
}

# 工作流：截图并分析
workflow_analyze_screen() {
    echo "=== Analyzing screen ==="
    
    # 1. 截图
    echo "1. Taking screenshot..."
    $CONTROL screenshot "C:\Temp\analysis.png"
    echo ""
    
    # 2. 列出窗口
    echo "2. Listing windows..."
    $CONTROL window list
    echo ""
    
    echo "=== Analysis complete ==="
    echo "Screenshot saved to C:\Temp\analysis.png"
}

# 主菜单
case "$1" in
    broadcast)
        workflow_broadcast "$2"
        ;;
    open_app)
        workflow_open_app "$2"
        ;;
    analyze)
        workflow_analyze_screen
        ;;
    *)
        echo "Workflow Engine"
        echo ""
        echo "Usage: $0 <workflow> [parameters]"
        echo ""
        echo "Workflows:"
        echo "  broadcast <message>  - Send message to Hermes and Codex"
        echo "  open_app <name>      - Find and open an application"
        echo "  analyze              - Analyze current screen"
        echo ""
        echo "Examples:"
        echo "  $0 broadcast 'Hello everyone'"
        echo "  $0 open_app notepad"
        echo "  $0 analyze"
        ;;
esac
