#!/bin/bash
# 快速鼠标键盘控制 - 阿砚专用
# 用法: ./quick_control.sh <action> [参数]

PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
SCRIPT="C:\\Temp\\win_input.ps1"

case "$1" in
    # 鼠标操作
    move)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_move -X "$2" -Y "$3"
        ;;
    click)
        BTN=0
        [ "$4" = "right" ] && BTN=1
        [ "$4" = "middle" ] && BTN=2
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_click -X "$2" -Y "$3" -Button "$BTN"
        ;;
    dclick)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_dclick -X "$2" -Y "$3"
        ;;
    rclick)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_rclick -X "$2" -Y "$3"
        ;;
    scroll)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_scroll -X "$2" -Y "$3" -Delta "$4"
        ;;
    
    # 键盘操作
    type)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_type -Text "$2"
        ;;
    hotkey)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "$2"
        ;;
    press)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_press -Keys "$2"
        ;;
    
    # 查询
    pos)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action mouse_pos
        ;;
    screen)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action screen_size
        ;;
    ss|screenshot)
        OUT="${2:-C:\\Temp\\screenshot.png}"
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action screen_shot -OutPath "$OUT"
        ;;
    
    # 批量操作（从 JSON 文件）
    batch)
        $PS -ExecutionPolicy Bypass -File "C:\\Temp\\win_batch.ps1" -CommandsFile "$2"
        ;;
    
    # 打开程序
    open)
        $PS -ExecutionPolicy Bypass -Command "Start-Process '$2'"
        ;;
    
    # 关闭窗口（Alt+F4）
    close)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "alt+f4"
        ;;
    
    # 最小化窗口（Win+Down）
    minimize)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "lwin+down"
        ;;
    
    # 最大化窗口（Win+Up）
    maximize)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "lwin+up"
        ;;
    
    # 切换窗口（Alt+Tab）
    switch)
        $PS -ExecutionPolicy Bypass -File "$SCRIPT" -Action key_hotkey -Keys "alt+tab"
        ;;
    
    *)
        echo "用法: $0 <action> [参数]"
        echo ""
        echo "鼠标:"
        echo "  move X Y           - 移动鼠标"
        echo "  click X Y [btn]    - 点击 (left|right|middle)"
        echo "  dclick X Y         - 双击"
        echo "  rclick X Y         - 右键"
        echo "  scroll X Y delta   - 滚轮"
        echo ""
        echo "键盘:"
        echo "  type \"text\"        - 输入文本"
        echo "  hotkey \"ctrl+c\"    - 快捷键"
        echo "  press \"enter\"      - 按键"
        echo ""
        echo "查询:"
        echo "  pos                - 鼠标位置"
        echo "  screen             - 屏幕尺寸"
        echo "  ss [path]          - 截图"
        echo ""
        echo "窗口:"
        echo "  open <program>     - 打开程序"
        echo "  close              - 关闭窗口 (Alt+F4)"
        echo "  minimize           - 最小化"
        echo "  maximize           - 最大化"
        echo "  switch             - 切换窗口"
        echo ""
        echo "批量:"
        echo "  batch <json_file>  - 批量操作"
        ;;
esac
