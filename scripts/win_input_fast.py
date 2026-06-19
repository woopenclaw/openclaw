#!/usr/bin/env python3
"""
Windows 鼠标键盘控制 - Python 快速版
通过 ctypes 直接调用 Win32 API，无需启动 PowerShell
"""

import ctypes
import ctypes.wintypes
import time
import sys
import json

# 加载 user32.dll
user32 = ctypes.windll.user32

# 常量定义
MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_RIGHTDOWN = 0x0008
MOUSEEVENTF_RIGHTUP = 0x0010
MOUSEEVENTF_MIDDLEDOWN = 0x0020
MOUSEEVENTF_MIDDLEUP = 0x0040
MOUSEEVENTF_WHEEL = 0x0800

KEYEVENTF_KEYDOWN = 0x0000
KEYEVENTF_KEYUP = 0x0002
KEYEVENTF_EXTENDEDKEY = 0x0001

# 虚拟键码映射
VK_MAP = {
    'enter': 0x0D, 'tab': 0x09, 'escape': 0x1B, 'esc': 0x1B,
    'space': 0x20, 'backspace': 0x08, 'delete': 0x2E, 'del': 0x2E,
    'insert': 0x2D, 'home': 0x24, 'end': 0x23,
    'pageup': 0x21, 'pagedown': 0x22,
    'up': 0x26, 'down': 0x28, 'left': 0x25, 'right': 0x27,
    'f1': 0x70, 'f2': 0x71, 'f3': 0x72, 'f4': 0x73,
    'f5': 0x74, 'f6': 0x75, 'f7': 0x76, 'f8': 0x77,
    'f9': 0x78, 'f10': 0x79, 'f11': 0x7A, 'f12': 0x7B,
    'ctrl': 0x11, 'lctrl': 0xA2, 'rctrl': 0xA3,
    'alt': 0x12, 'lalt': 0xA4, 'ralt': 0xA5,
    'shift': 0x10, 'lshift': 0xA0, 'rshift': 0xA1,
    'win': 0x5B, 'lwin': 0x5B, 'rwin': 0x5C,
    'capslock': 0x14, 'printscreen': 0x2C, 'pause': 0x13,
}

def get_vk(key):
    """获取虚拟键码"""
    if len(key) == 1:
        return ord(key.upper())
    return VK_MAP.get(key.lower(), 0)

def mouse_move(x, y):
    """移动鼠标到绝对坐标"""
    user32.SetCursorPos(x, y)

def mouse_click(x, y, button='left'):
    """点击鼠标"""
    user32.SetCursorPos(x, y)
    time.sleep(0.05)
    
    if button == 'right':
        user32.mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
        time.sleep(0.05)
        user32.mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    elif button == 'middle':
        user32.mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0)
        time.sleep(0.05)
        user32.mouse_event(MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0)
    else:  # left
        user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        time.sleep(0.05)
        user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)

def mouse_dclick(x, y):
    """双击"""
    user32.SetCursorPos(x, y)
    time.sleep(0.05)
    user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.05)
    user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    time.sleep(0.08)
    user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.05)
    user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)

def mouse_scroll(x, y, delta):
    """滚轮"""
    user32.SetCursorPos(x, y)
    time.sleep(0.05)
    user32.mouse_event(MOUSEEVENTF_WHEEL, 0, 0, delta * 120, 0)

def mouse_pos():
    """获取鼠标位置"""
    class POINT(ctypes.Structure):
        _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]
    
    pt = POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y

def screen_size():
    """获取屏幕尺寸"""
    w = user32.GetSystemMetrics(0)  # SM_CXSCREEN
    h = user32.GetSystemMetrics(1)  # SM_CYSCREEN
    return w, h

def key_press(key):
    """按下并释放单键"""
    vk = get_vk(key)
    if vk == 0:
        print(f"ERROR: unknown key '{key}'")
        return
    
    user32.keybd_event(vk, 0, KEYEVENTF_KEYDOWN, 0)
    time.sleep(0.05)
    user32.keybd_event(vk, 0, KEYEVENTF_KEYUP, 0)

def key_hotkey(combo):
    """快捷键组合，如 ctrl+c, alt+f4"""
    parts = combo.split('+')
    
    # Key down
    for p in parts:
        vk = get_vk(p.strip())
        if vk > 0:
            user32.keybd_event(vk, 0, KEYEVENTF_KEYDOWN, 0)
            time.sleep(0.03)
    
    time.sleep(0.05)
    
    # Key up (reverse order)
    for p in reversed(parts):
        vk = get_vk(p.strip())
        if vk > 0:
            user32.keybd_event(vk, 0, KEYEVENTF_KEYUP, 0)
            time.sleep(0.03)

def key_type_text(text):
    """输入文本（通过剪贴板）"""
    import subprocess
    
    # 设置剪贴板内容
    subprocess.run(['powershell.exe', '-Command', 
                    f'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::SetText("{text}")'],
                   capture_output=True)
    time.sleep(0.1)
    
    # Ctrl+V 粘贴
    user32.keybd_event(0x11, 0, KEYEVENTF_KEYDOWN, 0)  # Ctrl down
    time.sleep(0.03)
    user32.keybd_event(0x56, 0, KEYEVENTF_KEYDOWN, 0)  # V down
    time.sleep(0.03)
    user32.keybd_event(0x56, 0, KEYEVENTF_KEYUP, 0)    # V up
    time.sleep(0.03)
    user32.keybd_event(0x11, 0, KEYEVENTF_KEYUP, 0)    # Ctrl up

def screenshot(output_path):
    """截图"""
    import subprocess
    subprocess.run(['powershell.exe', '-ExecutionPolicy', 'Bypass', '-File', 
                    r'C:\Temp\win_input.ps1', '-Action', 'screen_shot', '-OutPath', output_path],
                   capture_output=True)

def main():
    if len(sys.argv) < 2:
        print("用法: python win_input_fast.py <action> [参数]")
        print("  mouse_move X Y")
        print("  mouse_click X Y [left|right|middle]")
        print("  mouse_dclick X Y")
        print("  mouse_scroll X Y delta")
        print("  mouse_pos")
        print("  screen_size")
        print("  key_press <key>")
        print("  key_hotkey <combo>")
        print("  key_type <text>")
        print("  screenshot <path>")
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == 'mouse_move':
        x, y = int(sys.argv[2]), int(sys.argv[3])
        mouse_move(x, y)
        print(f"OK: moved to ({x}, {y})")
    
    elif action == 'mouse_click':
        x, y = int(sys.argv[2]), int(sys.argv[3])
        button = sys.argv[4] if len(sys.argv) > 4 else 'left'
        mouse_click(x, y, button)
        print(f"OK: clicked ({x}, {y}) {button}")
    
    elif action == 'mouse_dclick':
        x, y = int(sys.argv[2]), int(sys.argv[3])
        mouse_dclick(x, y)
        print(f"OK: double-clicked ({x}, {y})")
    
    elif action == 'mouse_scroll':
        x, y = int(sys.argv[2]), int(sys.argv[3])
        delta = int(sys.argv[4])
        mouse_scroll(x, y, delta)
        print(f"OK: scrolled {delta} at ({x}, {y})")
    
    elif action == 'mouse_pos':
        x, y = mouse_pos()
        print(f"POS: {x},{y}")
    
    elif action == 'screen_size':
        w, h = screen_size()
        print(f"SCREEN: {w}x{h}")
    
    elif action == 'key_press':
        key = sys.argv[2]
        key_press(key)
        print(f"OK: pressed '{key}'")
    
    elif action == 'key_hotkey':
        combo = sys.argv[2]
        key_hotkey(combo)
        print(f"OK: hotkey '{combo}'")
    
    elif action == 'key_type':
        text = ' '.join(sys.argv[2:])
        key_type_text(text)
        print(f"OK: typed text")
    
    elif action == 'screenshot':
        path = sys.argv[2] if len(sys.argv) > 2 else r'C:\Temp\screenshot.png'
        screenshot(path)
        print(f"OK: saved to {path}")
    
    else:
        print(f"ERROR: unknown action '{action}'")
        sys.exit(1)

if __name__ == '__main__':
    main()
