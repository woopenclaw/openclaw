#!/bin/bash
# 统一电脑控制脚本
# 用法: ./computer_control.sh <target> <action> [参数]
#
# 示例:
#   ./computer_control.sh hermes send "你好"
#   ./computer_control.sh codex send "帮我写个脚本"
#   ./computer_control.sh window list
#   ./computer_control.sh window focus "Codex"
#   ./computer_control.sh app find "notepad"
#   ./computer_control.sh screenshot

PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass"
SCRIPTS_DIR="C:\\Temp"
COORD_DB="/home/administrator/.openclaw/workspace/scripts/coord_database.json"

# 读取坐标
get_coord() {
    local target=$1
    local coord_type=$2
    python3 -c "
import json
with open('$COORD_DB') as f:
    db = json.load(f)
coord = db.get('$target', {}).get('$coord_type', {})
if isinstance(coord, dict) and 'actual' in coord:
    print(f\"{coord['actual']['x']},{coord['actual']['y']}\")
elif isinstance(coord, dict) and 'x' in coord:
    print(f\"{coord['x']},{coord['y']}\")
else:
    print('')
"
}

case "$1" in
    hermes)
        case "$2" in
            send)
                MSG="${3:?Message required}"
                echo "Sending to Hermes: $MSG"
                $PS -ExecutionPolicy Bypass -Command "python $SCRIPTS_DIR\hermes_controller.py send '$MSG'"
                ;;
            screenshot)
                $PS -ExecutionPolicy Bypass -Command "python $SCRIPTS_DIR\hermes_controller.py screenshot"
                ;;
            *)
                echo "Usage: $0 hermes <send|screenshot> [message]"
                ;;
        esac
        ;;
    
    codex)
        case "$2" in
            send)
                MSG="${3:?Message required}"
                echo "Sending to Codex: $MSG"
                
                # 1. 最小化浏览器
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action minimize -Name "Edge"
                sleep 1
                
                # 2. 聚焦 Codex
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action focus -Name "Codex"
                sleep 1
                
                # 3. 点击输入框
                COORD=$(get_coord "codex" "input_box_coords")
                if [ -n "$COORD" ]; then
                    X=$(echo $COORD | cut -d',' -f1)
                    Y=$(echo $COORD | cut -d',' -f2)
                    $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action mouse_click -X $X -Y $Y
                    sleep 0.5
                    
                    # 4. 输入消息
                    $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action key_type -Text "$MSG"
                    sleep 0.5
                    
                    # 5. 发送
                    $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action key_press -Keys "enter"
                    sleep 2
                    
                    # 6. 截图确认
                    $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action screen_shot -OutPath "C:\Temp\codex_sent.png"
                    echo "Message sent to Codex"
                else
                    echo "ERROR: Codex input coordinates not found"
                fi
                ;;
            screenshot)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action screen_shot -OutPath "C:\Temp\codex_screen.png"
                ;;
            *)
                echo "Usage: $0 codex <send|screenshot> [message]"
                ;;
        esac
        ;;
    
    window)
        case "$2" in
            list)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action list
                ;;
            focus)
                NAME="${3:?Window name required}"
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action focus -Name "$NAME"
                ;;
            minimize)
                NAME="${3:?Window name required}"
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action minimize -Name "$NAME"
                ;;
            maximize)
                NAME="${3:?Window name required}"
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\window_manager.ps1" -Action maximize -Name "$NAME"
                ;;
            *)
                echo "Usage: $0 window <list|focus|minimize|maximize> [name]"
                ;;
        esac
        ;;
    
    app)
        case "$2" in
            find)
                NAME="${3:?App name required}"
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\find_app.ps1" "$NAME"
                ;;
            *)
                echo "Usage: $0 app find <name>"
                ;;
        esac
        ;;
    
    screenshot)
        OUT="${2:-C:\Temp\screenshot.png}"
        $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action screen_shot -OutPath "$OUT"
        echo "Screenshot saved to $OUT"
        ;;
    
    mouse)
        case "$2" in
            move)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action mouse_move -X "$3" -Y "$4"
                ;;
            click)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action mouse_click -X "$3" -Y "$4"
                ;;
            pos)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action mouse_pos
                ;;
            *)
                echo "Usage: $0 mouse <move|click|pos> [x] [y]"
                ;;
        esac
        ;;
    
    keyboard)
        case "$2" in
            type)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action key_type -Text "$3"
                ;;
            press)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action key_press -Keys "$3"
                ;;
            hotkey)
                $PS -ExecutionPolicy Bypass -File "$SCRIPTS_DIR\win_input.ps1" -Action key_hotkey -Keys "$3"
                ;;
            *)
                echo "Usage: $0 keyboard <type|press|hotkey> <text/keys>"
                ;;
        esac
        ;;
    
    *)
        echo "Computer Control Script"
        echo ""
        echo "Usage: $0 <target> <action> [parameters]"
        echo ""
        echo "Targets:"
        echo "  hermes <send|screenshot> [msg]  - Control Hermes Studio"
        echo "  codex <send|screenshot> [msg]   - Control Codex"
        echo "  window <list|focus|min|max> [name] - Window management"
        echo "  app find <name>                 - Search for applications"
        echo "  screenshot [path]               - Take screenshot"
        echo "  mouse <move|click|pos> [x] [y]  - Mouse control"
        echo "  keyboard <type|press|hotkey>    - Keyboard control"
        echo ""
        echo "Examples:"
        echo "  $0 hermes send 'Hello'"
        echo "  $0 codex send 'Help me'"
        echo "  $0 window list"
        echo "  $0 window focus Codex"
        echo "  $0 app find notepad"
        echo "  $0 screenshot"
        ;;
esac
