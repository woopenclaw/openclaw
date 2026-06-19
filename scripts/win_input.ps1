# Windows 鼠标键盘控制工具 - 从WSL调用
# 用法: powershell.exe -File win_input.ps1 -Action <action> [参数]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("mouse_move","mouse_click","mouse_rclick","mouse_dclick","mouse_scroll",
                 "key_type","key_hotkey","key_press",
                 "screen_shot","mouse_pos","screen_size")]
    [string]$Action,
    
    [int]$X = 0,
    [int]$Y = 0,
    [string]$Text = "",
    [string]$Keys = "",
    [int]$Button = 0,      # 0=left, 1=right, 2=middle
    [int]$Delta = 0,       # 滚轮量
    [string]$OutPath = ""  # 截图输出路径
)

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32Input {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);
    
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
    
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
    
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
    
    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int nIndex);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int X;
        public int Y;
    }
    
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
    public const uint MOUSEEVENTF_RIGHTUP = 0x0010;
    public const uint MOUSEEVENTF_MIDDLEDOWN = 0x0020;
    public const uint MOUSEEVENTF_MIDDLEUP = 0x0040;
    public const uint MOUSEEVENTF_WHEEL = 0x0800;
    public const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
    
    public const uint KEYEVENTF_KEYDOWN = 0x0000;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const uint KEYEVENTF_EXTENDEDKEY = 0x0001;
}
"@

Add-Type -AssemblyName System.Windows.Forms

function Get-VKCode {
    param([string]$key)
    $keyMap = @{
        "enter"=0x0D; "tab"=0x09; "escape"=0x1B; "space"=0x20; "backspace"=0x08
        "delete"=0x2E; "insert"=0x2D; "home"=0x24; "end"=0x23; "pageup"=0x21; "pagedown"=0x22
        "up"=0x26; "down"=0x28; "left"=0x25; "right"=0x27
        "f1"=0x70; "f2"=0x71; "f3"=0x72; "f4"=0x73; "f5"=0x74; "f6"=0x75
        "f7"=0x76; "f8"=0x77; "f9"=0x78; "f10"=0x79; "f11"=0x7A; "f12"=0x7B
        "ctrl"=0x11; "lctrl"=0xA2; "rctrl"=0xA3
        "alt"=0x12; "lalt"=0xA4; "ralt"=0xA5
        "shift"=0x10; "lshift"=0xA0; "rshift"=0xA1
        "win"=0x5B; "lwin"=0x5B; "rwin"=0x5C
        "capslock"=0x14; "numlock"=0x90; "scrolllock"=0x91
        "printscreen"=0x2C; "pause"=0x13
    }
    if ($key.Length -eq 1) {
        return [int][char]$key.ToUpper()
    }
    if ($keyMap.ContainsKey($key.ToLower())) {
        return $keyMap[$key.ToLower()]
    }
    return 0
}

switch ($Action) {
    "mouse_move" {
        [Win32Input]::SetCursorPos($X, $Y) | Out-Null
        Write-Host "OK: mouse moved to ($X, $Y)"
    }
    
    "mouse_click" {
        [Win32Input]::SetCursorPos($X, $Y) | Out-Null
        Start-Sleep -Milliseconds 50
        if ($Button -eq 1) {
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
        } elseif ($Button -eq 2) {
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0)
        } else {
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        }
        Write-Host "OK: clicked at ($X, $Y) button=$Button"
    }
    
    "mouse_dclick" {
        [Win32Input]::SetCursorPos($X, $Y) | Out-Null
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        Start-Sleep -Milliseconds 80
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        Write-Host "OK: double-clicked at ($X, $Y)"
    }
    
    "mouse_rclick" {
        [Win32Input]::SetCursorPos($X, $Y) | Out-Null
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
        Write-Host "OK: right-clicked at ($X, $Y)"
    }
    
    "mouse_scroll" {
        [Win32Input]::SetCursorPos($X, $Y) | Out-Null
        Start-Sleep -Milliseconds 50
        [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_WHEEL, 0, 0, [uint32]($Delta * 120), 0)
        Write-Host "OK: scrolled $Delta at ($X, $Y)"
    }
    
    "mouse_pos" {
        $pt = New-Object Win32Input+POINT
        [Win32Input]::GetCursorPos([ref]$pt) | Out-Null
        Write-Host "POS: $($pt.X),$($pt.Y)"
    }
    
    "screen_size" {
        $w = [Win32Input]::GetSystemMetrics(0)  # SM_CXSCREEN
        $h = [Win32Input]::GetSystemMetrics(1)  # SM_CYSCREEN
        Write-Host "SCREEN: ${w}x${h}"
    }
    
    "key_type" {
        # 输入文本（支持中文，通过剪贴板）
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::SetText($Text)
        Start-Sleep -Milliseconds 100
        # Ctrl+V 粘贴
        [Win32Input]::keybd_event(0x11, 0, [Win32Input]::KEYEVENTF_KEYDOWN, 0)  # Ctrl down
        Start-Sleep -Milliseconds 30
        [Win32Input]::keybd_event(0x56, 0, [Win32Input]::KEYEVENTF_KEYDOWN, 0)  # V down
        Start-Sleep -Milliseconds 30
        [Win32Input]::keybd_event(0x56, 0, [Win32Input]::KEYEVENTF_KEYUP, 0)    # V up
        Start-Sleep -Milliseconds 30
        [Win32Input]::keybd_event(0x11, 0, [Win32Input]::KEYEVENTF_KEYUP, 0)    # Ctrl up
        Write-Host "OK: typed text via clipboard"
    }
    
    "key_hotkey" {
        # 快捷键: "ctrl+c", "alt+f4", "ctrl+shift+s" 等
        $parts = $Keys.Split('+')
        # Key down
        foreach ($p in $parts) {
            $vk = Get-VKCode $p.Trim()
            if ($vk -gt 0) {
                [Win32Input]::keybd_event([byte]$vk, 0, [Win32Input]::KEYEVENTF_KEYDOWN, 0)
                Start-Sleep -Milliseconds 30
            }
        }
        Start-Sleep -Milliseconds 50
        # Key up (reverse order)
        for ($i = $parts.Length - 1; $i -ge 0; $i--) {
            $vk = Get-VKCode $parts[$i].Trim()
            if ($vk -gt 0) {
                [Win32Input]::keybd_event([byte]$vk, 0, [Win32Input]::KEYEVENTF_KEYUP, 0)
                Start-Sleep -Milliseconds 30
            }
        }
        Write-Host "OK: hotkey '$Keys'"
    }
    
    "key_press" {
        # 单键按下释放
        $vk = Get-VKCode $Keys
        if ($vk -gt 0) {
            [Win32Input]::keybd_event([byte]$vk, 0, [Win32Input]::KEYEVENTF_KEYDOWN, 0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::keybd_event([byte]$vk, 0, [Win32Input]::KEYEVENTF_KEYUP, 0)
            Write-Host "OK: pressed '$Keys' (VK=$vk)"
        } else {
            Write-Host "ERROR: unknown key '$Keys'"
        }
    }
    
    "screen_shot" {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen
        $bmp = New-Object System.Drawing.Bitmap($screen.Bounds.Width, $screen.Bounds.Height)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.CopyFromScreen($screen.Bounds.Location, [System.Drawing.Point]::Empty, $screen.Bounds.Size)
        $outFile = if ($OutPath) { $OutPath } else { "$env:TEMP\screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png" }
        $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose()
        $bmp.Dispose()
        Write-Host "OK: saved to $outFile"
    }
}
