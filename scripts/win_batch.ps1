# 批量鼠标键盘控制脚本
# 从 JSON 文件读取操作序列，一次执行

param(
    [string]$CommandsFile = ""
)

if (-not $CommandsFile) {
    Write-Host "用法: powershell -File win_batch.ps1 -CommandsFile <json文件>"
    exit 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Input {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, uint d, int e);
    [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte sc, uint f, int e);
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT lp);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int n);
    [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
    public const uint MOUSEEVENTF_LEFTDOWN=0x0002; public const uint MOUSEEVENTF_LEFTUP=0x0004;
    public const uint MOUSEEVENTF_RIGHTDOWN=0x0008; public const uint MOUSEEVENTF_RIGHTUP=0x0010;
    public const uint MOUSEEVENTF_MIDDLEDOWN=0x0020; public const uint MOUSEEVENTF_MIDDLEUP=0x0040;
    public const uint MOUSEEVENTF_WHEEL=0x0800;
    public const uint KEYEVENTF_KEYDOWN=0x0000; public const uint KEYEVENTF_KEYUP=0x0002;
}
"@

Add-Type -AssemblyName System.Windows.Forms

$commands = Get-Content $CommandsFile | ConvertFrom-Json

foreach ($cmd in $commands) {
    switch ($cmd.action) {
        "move" {
            [Win32Input]::SetCursorPos($cmd.x, $cmd.y) | Out-Null
        }
        "click" {
            [Win32Input]::SetCursorPos($cmd.x, $cmd.y) | Out-Null
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN,0,0,0,0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP,0,0,0,0)
        }
        "rclick" {
            [Win32Input]::SetCursorPos($cmd.x, $cmd.y) | Out-Null
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_RIGHTUP,0,0,0,0)
        }
        "dclick" {
            [Win32Input]::SetCursorPos($cmd.x, $cmd.y) | Out-Null
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN,0,0,0,0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP,0,0,0,0)
            Start-Sleep -Milliseconds 80
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTDOWN,0,0,0,0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_LEFTUP,0,0,0,0)
        }
        "scroll" {
            [Win32Input]::SetCursorPos($cmd.x, $cmd.y) | Out-Null
            Start-Sleep -Milliseconds 50
            [Win32Input]::mouse_event([Win32Input]::MOUSEEVENTF_WHEEL,0,0,[uint32]($cmd.delta*120),0)
        }
        "type" {
            [System.Windows.Forms.Clipboard]::SetText($cmd.text)
            Start-Sleep -Milliseconds 100
            [Win32Input]::keybd_event(0x11,0,[Win32Input]::KEYEVENTF_KEYDOWN,0)
            Start-Sleep -Milliseconds 30
            [Win32Input]::keybd_event(0x56,0,[Win32Input]::KEYEVENTF_KEYDOWN,0)
            Start-Sleep -Milliseconds 30
            [Win32Input]::keybd_event(0x56,0,[Win32Input]::KEYEVENTF_KEYUP,0)
            Start-Sleep -Milliseconds 30
            [Win32Input]::keybd_event(0x11,0,[Win32Input]::KEYEVENTF_KEYUP,0)
        }
        "key" {
            $vk = [int]$cmd.vk
            [Win32Input]::keybd_event([byte]$vk,0,[Win32Input]::KEYEVENTF_KEYDOWN,0)
            Start-Sleep -Milliseconds 50
            [Win32Input]::keybd_event([byte]$vk,0,[Win32Input]::KEYEVENTF_KEYUP,0)
        }
        "wait" {
            Start-Sleep -Milliseconds $cmd.ms
        }
        "screenshot" {
            Add-Type -AssemblyName System.Drawing
            $scr = [System.Windows.Forms.Screen]::PrimaryScreen
            $bmp = New-Object System.Drawing.Bitmap($scr.Bounds.Width, $scr.Bounds.Height)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.CopyFromScreen($scr.Bounds.Location, [System.Drawing.Point]::Empty, $scr.Bounds.Size)
            $bmp.Save($cmd.path, [System.Drawing.Imaging.ImageFormat]::Png)
            $g.Dispose(); $bmp.Dispose()
        }
    }
}

Write-Host "OK: batch executed"
