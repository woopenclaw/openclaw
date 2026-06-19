#!/bin/bash
# Windows 鼠标键盘控制 - WSL侧封装
# 用法: ./win_control.sh <action> [参数]
#
# 示例:
#   ./win_control.sh screenshot [输出路径]
#   ./win_control.sh move 500 300
#   ./win_control.sh click 500 300 [left|right|middle]
#   ./win_control.sh dclick 500 300
#   ./win_control.sh scroll 500 300 3
#   ./win_control.sh type "你好世界"
#   ./win_control.sh hotkey "ctrl+c"
#   ./win_control.sh hotkey "alt+f4"
#   ./win_control.sh hotkey "ctrl+shift+s"
#   ./win_control.sh press "enter"
#   ./win_control.sh press "escape"
#   ./win_control.sh pos
#   ./win_control.sh screen

PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
SCRIPT="C:\\Temp\\win_input.ps1"

case "$1" in
    screenshot|ss)
        OUT="${2:-C:\\Temp\\screenshot.png}"
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action screen_shot -OutPath "$OUT"
        ;;
    move|mv)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_move -X "$2" -Y "$3"
        ;;
    click|ck)
        BTN=0
        case "$4" in right) BTN=1;; middle) BTN=2;; esac
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_click -X "$2" -Y "$3" -Button "$BTN"
        ;;
    dclick|dk)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_dclick -X "$2" -Y "$3"
        ;;
    rclick|rk)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_rclick -X "$2" -Y "$3"
        ;;
    scroll|sc)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_scroll -X "$2" -Y "$3" -Delta "$4"
        ;;
    type|tp)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_type -Text "$2"
        ;;
    hotkey|hk)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "$2"
        ;;
    press|pr)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_press -Keys "$2"
        ;;
    pos)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_pos
        ;;
    screen|sz)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action screen_size
        ;;
    *)
        echo "用法: $0 <action> [参数]"
        echo "  screenshot [path]  - 截图"
        echo "  move X Y           - 移动鼠标"
        echo "  click X Y [btn]    - 点击 (left|right|middle)"
        echo "  dclick X Y         - 双击"
        echo "  rclick X Y         - 右键"
        echo "  scroll X Y delta   - 滚轮 (正=上,负=下)"
        echo "  type \"text\"        - 输入文本(支持中文)"
        echo "  hotkey \"ctrl+c\"    - 快捷键"
        echo "  press \"enter\"      - 按键"
        echo "  pos                - 鼠标位置"
        echo "  screen             - 屏幕尺寸"
        ;;
esac
