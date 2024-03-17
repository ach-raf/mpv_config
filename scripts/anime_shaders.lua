-----
-----    Mode A (Optimized for 1080p Anime).
-----    Mode B (Optimized for 720p Anime).
-----    Mode C (Optimized for 480p Anime).
-----    clear all shaders (Disable Anime4K).
----

-- Define the shader modes and corresponding commands
local shaderModes = {
    [1] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode A (Fast)"
    },
    [2] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode B (Fast)"
    },
    [3] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode C (Fast)"
    },
    [4] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_S.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode A+A (Fast)"
    },
    [5] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Restore_CNN_Soft_S.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode B+B (Fast)"
    },
    [6] = {
        cmd = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Restore_CNN_S.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"",
        text = "Anime4K: Mode C+A (Fast)"
    },
    [7] = {
        cmd = "no-osd change-list glsl-shaders clr \"\"",
        text = "GLSL shaders cleared"
    },
}

-- Variable to keep track of the current mode
local currentMode = 3

-- Function to switch to the next mode or clear shaders
function switchMode()
    local mode = shaderModes[currentMode]
    mp.command(mode.cmd)
    mp.command("show-text \"" .. mode.text .. "\"")

    -- Increment currentMode or reset to 1 if it exceeds the number of modes
    currentMode = (currentMode % #shaderModes) + 1
end

-- Function to show the currently selected mode
function showCurrentMode()
    local show_text_index = currentMode
    local mode = shaderModes[show_text_index]
    mp.command("show-text \"" .. mode.text .. "\"")
end

-- Bind the key combination Ctrl+2 to show the currently selected mode
mp.add_key_binding("ctrl+shift+2", "show_current_mode", showCurrentMode)

-- Bind the key combination Ctrl+1 to switch between modes and clear shaders
mp.add_key_binding("ctrl+shift+x", "switch_mode", switchMode)
-- Automatically select "Anime4K: Mode C (Fast)" shader on startup
mp.command(shaderModes[3].cmd)