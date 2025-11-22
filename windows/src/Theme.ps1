# ========== THEME ========== #

function Set-Theme {
    switch ($script:THEME) {
        "msf" {
            # Default MSF colors
            $script:COLOR_RED = "Red"
            $script:COLOR_GREEN = "Green"
            $script:COLOR_YELLOW = "Yellow"
            $script:COLOR_BLUE = "Blue"
            $script:COLOR_MAGENTA = "Magenta"
            $script:COLOR_CYAN = "Cyan"
        }
        "dark" {
            # Dark theme
            $script:COLOR_RED = "DarkRed"
            $script:COLOR_GREEN = "DarkGreen"
            $script:COLOR_YELLOW = "DarkYellow"
            $script:COLOR_BLUE = "DarkBlue"
            $script:COLOR_MAGENTA = "DarkMagenta"
            $script:COLOR_CYAN = "DarkCyan"
        }
        "light" {
            # Light theme (bright colors)
            $script:COLOR_RED = "Red"
            $script:COLOR_GREEN = "Green"
            $script:COLOR_YELLOW = "Yellow"
            $script:COLOR_BLUE = "Cyan"
            $script:COLOR_MAGENTA = "Magenta"
            $script:COLOR_CYAN = "Cyan"
        }
        "minimal" {
            # Minimal colors
            $script:COLOR_RED = "Red"
            $script:COLOR_GREEN = "Green"
            $script:COLOR_YELLOW = "Yellow"
            $script:COLOR_BLUE = "Blue"
            $script:COLOR_MAGENTA = "Magenta"
            $script:COLOR_CYAN = "Cyan"
        }
        default {
            Log-Warning "Unknown theme '$THEME', using default MSF theme"
            $script:THEME = "msf"
            Set-Theme
        }
    }
}
