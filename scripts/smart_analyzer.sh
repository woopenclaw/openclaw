#!/bin/bash
# 智能分析框架 - 截图后自动识别元素

SCRIPTS_DIR="/home/administrator/.openclaw/workspace/scripts"
SCREENSHOTS_DIR="/home/administrator/.openclaw/workspace/screenshots"
ANALYSIS_DIR="/home/administrator/.openclaw/workspace/analysis"

mkdir -p "$ANALYSIS_DIR"

# 截图并分析
analyze_screen() {
    local DESC="$1"
    local TIMESTAMP=$(date +%s)
    local SCREENSHOT="$SCREENSHOTS_DIR/analysis_${TIMESTAMP}.png"
    local ANALYSIS="$ANALYSIS_DIR/analysis_${TIMESTAMP}.txt"
    
    echo "=== 开始分析: $DESC ==="
    
    # 1. 截图
    echo "1. 截图..."
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "& 'C:\Temp\win_input.ps1' -Action screen_shot -OutPath 'C:\Temp\current_analysis.png'" 2>/dev/null
    cp /mnt/c/Temp/current_analysis.png "$SCREENSHOT"
    echo "   截图保存: $SCREENSHOT"
    
    # 2. 获取窗口列表
    echo "2. 获取窗口列表..."
    local WINDOWS=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "Get-Process | Where-Object { \$_.MainWindowTitle -ne '' } | Select-Object Id, ProcessName, MainWindowTitle | Format-Table -AutoSize")
    echo "$WINDOWS" > "$ANALYSIS"
    echo "$WINDOWS"
    
    # 3. 获取鼠标位置
    echo "3. 获取鼠标位置..."
    local MOUSE_POS=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "& 'C:\Temp\win_input.ps1' -Action mouse_pos")
    echo "鼠标位置: $MOUSE_POS" | tee -a "$ANALYSIS"
    
    # 4. 获取屏幕尺寸
    echo "4. 获取屏幕尺寸..."
    local SCREEN_SIZE=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "& 'C:\Temp\win_input.ps1' -Action screen_size")
    echo "屏幕尺寸: $SCREEN_SIZE" | tee -a "$ANALYSIS"
    
    # 5. 保存分析结果
    echo "" >> "$ANALYSIS"
    echo "分析时间: $(date)" >> "$ANALYSIS"
    echo "描述: $DESC" >> "$ANALYSIS"
    
    echo ""
    echo "=== 分析完成 ==="
    echo "截图: $SCREENSHOT"
    echo "分析: $ANALYSIS"
    
    # 返回截图路径供AI分析
    echo "$SCREENSHOT"
}

# 查找特定元素
find_element() {
    local ELEMENT_DESC="$1"
    local SCREENSHOT="$2"
    
    echo "=== 查找元素: $ELEMENT_DESC ==="
    echo "截图: $SCREENSHOT"
    echo ""
    echo "请使用 image 工具分析此截图，查找: $ELEMENT_DESC"
    echo "返回元素的位置坐标（显示坐标，需要×1.28转换为实际坐标）"
}

# 主函数
case "$1" in
    screen)
        analyze_screen "$2"
        ;;
    find)
        find_element "$2" "$3"
        ;;
    *)
        echo "智能分析框架"
        echo ""
        echo "用法: $0 <action> [parameters]"
        echo ""
        echo "Actions:"
        echo "  screen <description>  - 截图并分析当前屏幕"
        echo "  find <element> <screenshot> - 查找特定元素"
        ;;
esac
