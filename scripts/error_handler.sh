#!/bin/bash
# 错误处理框架 - 自动重试 + 截图 + 日志

LOG_FILE="/home/administrator/.openclaw/workspace/logs/computer_control.log"
MAX_RETRIES=3
RETRY_DELAY=2

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    local MSG="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$MSG"
    echo "$MSG" >> "$LOG_FILE"
}

log_error() {
    log "ERROR: $1"
}

log_success() {
    log "SUCCESS: $1"
}

# 执行命令并自动重试
retry_command() {
    local CMD="$1"
    local DESC="$2"
    local ATTEMPT=1
    
    log "Executing: $DESC"
    log "Command: $CMD"
    
    while [ $ATTEMPT -le $MAX_RETRIES ]; do
        log "  Attempt $ATTEMPT/$MAX_RETRIES"
        
        # 执行命令
        if bash -c "$CMD" 2>&1; then
            log_success "$DESC (attempt $ATTEMPT)"
            return 0
        else
            local EXIT_CODE=$?
            log_error "$DESC failed (attempt $ATTEMPT, exit code: $EXIT_CODE)"
            
            # 失败时截图
            /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
                "& 'C:\Temp\win_input.ps1' -Action screen_shot -OutPath 'C:\Temp\error_attempt${ATTEMPT}.png'" 2>/dev/null
            
            if [ $ATTEMPT -lt $MAX_RETRIES ]; then
                log "  Retrying in ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
            fi
        fi
        
        ATTEMPT=$((ATTEMPT + 1))
    done
    
    log_error "$DESC failed after $MAX_RETRIES attempts"
    return 1
}

# 检查窗口是否存在
check_window() {
    local WINDOW_NAME="$1"
    local RESULT=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "Get-Process | Where-Object { \$_.MainWindowTitle -like '*$WINDOW_NAME*' } | Select-Object -First 1 | ForEach-Object { \$_.Id }")
    
    if [ -n "$RESULT" ]; then
        log "Window '$WINDOW_NAME' found (PID: $RESULT)"
        return 0
    else
        log_error "Window '$WINDOW_NAME' not found"
        return 1
    fi
}

# 检查进程是否运行
check_process() {
    local PROCESS_NAME="$1"
    local RESULT=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -Command \
        "Get-Process -Name '$PROCESS_NAME' -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object { \$_.Id }")
    
    if [ -n "$RESULT" ]; then
        log "Process '$PROCESS_NAME' running (PID: $RESULT)"
        return 0
    else
        log_error "Process '$PROCESS_NAME' not running"
        return 1
    fi
}

# 主函数
case "$1" in
    retry)
        retry_command "$2" "$3"
        ;;
    check-window)
        check_window "$2"
        ;;
    check-process)
        check_process "$2"
        ;;
    log)
        log "$2"
        ;;
    *)
        echo "Error Handler Framework"
        echo ""
        echo "Usage: $0 <action> [parameters]"
        echo ""
        echo "Actions:"
        echo "  retry <command> <description>  - Execute with auto-retry"
        echo "  check-window <name>            - Check if window exists"
        echo "  check-process <name>           - Check if process is running"
        echo "  log <message>                  - Write to log"
        ;;
esac
