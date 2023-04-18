Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Mouse {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetCursorPos(int x, int y);

        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out POINT lpPoint);

        public struct POINT {
            public int X;
            public int Y;

            public POINT(int x, int y) {
                this.X = x;
                this.Y = y;
            }
        }
    }

    public class Hotkey {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool UnregisterHotKey(IntPtr hWnd, int id);

        public const int WM_HOTKEY = 0x0312;

        public const uint MOD_NONE = 0x0000;
        public const uint MOD_ALT = 0x0001;
        public const uint MOD_CONTROL = 0x0002;
        public const uint MOD_SHIFT = 0x0004;
        public const uint MOD_WIN = 0x0008;
    }
"@

function Main {
    $mouse_moving = $false

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Keep Mouse Moving"
    $form.Size = New-Object System.Drawing.Size(0, 0)
    $form.StartPosition = "Manual"
    $form.Location = New-Object System.Drawing.Point(-100, -100)

    $form.Add_KeyDown({
        if ($_.KeyCode -eq "F12") {
            $mouse_moving = !$mouse_moving
            if ($mouse_moving) {
                Write-Host "Mouse moving started. Press F12 to stop."
            } else {
                Write-Host "Mouse moving stopped. Press F12 to start."
            }
        }
    })

    $form.Add_FormClosing({
        [Hotkey]::UnregisterHotKey($form.Handle, 0)
    })

    [Hotkey]::RegisterHotKey($form.Handle, 0, [Hotkey]::MOD_NONE, [System.Windows.Forms.Keys]::F12)

    Write-Host "Press F12 to start/stop mouse moving. Press CTRL+C to exit."

    while ($true) {
        if ($mouse_moving) {
            $current_position = New-Object Mouse+POINT
            [Mouse]::GetCursorPos([ref]$current_position)
            $new_position = New-Object Mouse+POINT($current_position.X + 1, $current_position.Y + 1)
            [Mouse]::SetCursorPos($new_position.X, $new_position.Y)
            Start-Sleep -Milliseconds 100
            [Mouse]::SetCursorPos($current_position.X, $current_position.Y)
            Start-Sleep -Milliseconds 9900
        } else {
            $null = $form.ShowDialog()
        }
    }
}

Main
