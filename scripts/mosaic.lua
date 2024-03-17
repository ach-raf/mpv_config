-- mosaic.lua
-- This script will take screenshots of a video and create a mosaic of those screenshots.
-- It will take screenshots of a determined number of rows and columns, and then create
-- a montage of those screenshots.
--
-- Created by: noaione (original JavaScript version)
-- Lua rewrite by: Claude (Anthropic AI)
-- License: MIT
-- Version: 2024.03.09.1

local utils = require("mp.utils")
local msg = require("mp.msg")
local opt = require("mp.options")

-- Default options
local options = {
    -- Number of rows for screenshot
    rows = 3,
    -- Number of columns for screenshot
    columns = 4,
    -- Padding between screenshots (pixels)
    padding = 10,
    -- Output format ("png", "jpg", or "webp")
    format = "png",
    -- Screenshot mode ("video", "subtitles", or "window")
    mode = "video",
    -- Append the "magick" command to the command line (boolean)
    append_magick = false,
    -- Resize the final montage to the video height (boolean)
    resize = true,
    -- Output image quality (0-100)
    quality = 90,
}

opt.read_options(options, "screenshot-mosaic")

-- Helper functions
local function join_paths(...)
    return utils.join_path(...)
end

local function dump(...)
    local args = {...}
    for i = 1, #args do
        msg.info(args[i])
    end
end

local function run_cmd(args, callback)
    local res = utils.subprocess({args = args, cancellable = false})
    if callback then
        callback(res)
    end
    return res
end

local function check_magick()
    local cmd = options.append_magick and {"magick", "montage"} or {"montage"}
    table.insert(cmd, "--version")
    local res = run_cmd(cmd)
    return res.status == 0
end

local function get_video_info()
    local duration = mp.get_property_number("duration")
    local width = mp.get_property_number("width")
    local height = mp.get_property_number("height")
    return duration, width, height
end

local function format_duration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds - hours * 3600) / 60)
    local seconds = math.floor(seconds - hours * 3600 - minutes * 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function humanize_bytes(bytes)
    if not bytes then
        return "?? B"
    end
    local thresh = 1024
    if math.abs(bytes) < thresh then
        return bytes .. " B"
    end
    local units = {"kiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"}
    local u = 1
    while math.abs(bytes) >= thresh and u < #units do
        bytes = bytes / thresh
        u = u + 1
    end
    return string.format("%.1f %s", bytes, units[u])
end

local function create_output_name(filename, options)
    local final_name = filename:gsub(" ", "_")
    local mosaic_name = ".mosaic" .. options.columns .. "x" .. options.rows
    local test_count = #final_name + #mosaic_name
    if test_count > 224 then
        final_name = final_name:sub(1, -test_count + 223)
    end
    return final_name .. mosaic_name
end

local function get_output_dir()
    return "C:\\tools\\mpv\\portable_config\\screenshots"
end

local function create_mosaic(screenshots, output_file, callback)
    local duration, width, height = get_video_info()
    if not duration or not width or not height then
        msg.error("Failed to get video information.")
        if callback then
            callback(false)
        end
        return
    end

    local filename = mp.get_property("filename")
    local formatted_duration = format_duration(duration)
    local montage_file = output_file 
    


    local function join_args(args)
        local result = {}
        for _, arg in ipairs(args) do
            if arg ~= nil then
                table.insert(result, arg)
            end
        end
        return result
    end

    local montage_cmd = {
        options.append_magick and "magick" or nil,
        "montage",
        "-geometry", width .. "x" .. height .. "+" .. options.padding .. "+" .. options.padding,
    }

    -- Convert screenshots to a regular Lua table
    local screenshots_table = {}
    for i = 1, #screenshots do
        table.insert(screenshots_table, screenshots[i])
    end

    for _, screenshot in ipairs(screenshots_table) do
        table.insert(montage_cmd, screenshot)
    end

    table.insert(montage_cmd, montage_file)
    montage_cmd = join_args(montage_cmd)

    msg.info("Creating image montage: " .. montage_file)
    dump(montage_cmd)

    run_cmd(montage_cmd, function(res)
        if res.status == 0 then
            if options.resize then
                local resize_cmd = {
                    options.append_magick and "magick" or nil,
                    "convert",
                    montage_file,
                    "-resize", "x" .. height,
                    montage_file,
                }
                resize_cmd = utils.join_nested_array(resize_cmd)

                msg.info("Resizing image to x" .. height .. ": " .. montage_file)
                dump(resize_cmd)

                run_cmd(resize_cmd, function(res)
                    if res.status == 0 then
                        local annotate_cmd = {
                            options.append_magick and "magick" or nil,
                            "convert",
                            "-background", "white",
                            "-pointsize", "40",
                            "-gravity", "northwest",
                            "label:mpv Media Player",
                            "-splice", "0x10",
                            "-pointsize", "16",
                            "-gravity", "northwest",
                            "label:File Name: " .. filename,
                            "label:File Size: " .. humanize_bytes(mp.get_property_number("file-size")),
                            "label:Resolution: " .. width .. "x" .. height,
                            "label:Duration: " .. formatted_duration,
                            "-splice", "10x0",
                            montage_file,
                            "-append",
                            "-quality", options.quality .. "%",
                            output_file,
                        }
                        annotate_cmd = utils.join_nested_array(annotate_cmd)

                        msg.info("Annotating image: " .. output_file)
                        dump(annotate_cmd)

                        run_cmd(annotate_cmd, function(res)
                            if res.status == 0 then
                                msg.info("Mosaic created for " .. options.columns .. "x" .. options.rows .. " images at " .. output_file)
                                mp.osd_message("Mosaic created!\n{\\b1}" .. output_file .. "{\\b0}", 5)
                            else
                                msg.error("Failed to annotate image.")
                            end
                            if callback then
                                callback(res.status == 0)
                            end
                        end)
                    else
                        msg.error("Failed to resize image.")
                        if callback then
                            callback(false)
                        end
                    end
                end)
            else
                if callback then
                    callback(true)
                end
            end
        else
            msg.error("Failed to create montage.")
            if callback then
                callback(false)
            end
        end
    end)
end

local function take_screenshots(start_time, time_step, callback)
    local screenshots = {}
    local screenshot_dir = get_output_dir()

    local function screenshot_cycle(counter)
        if counter > options.rows * options.columns then
            callback(screenshots)
            return
        end

        local time_pos = start_time + (counter - 1) * time_step
        mp.commandv("seek", time_pos, "absolute", "exact")
        local screenshot_path = join_paths(screenshot_dir, "temp_screenshot-" .. counter .. "." .. options.format)
        mp.commandv("screenshot-to-file", screenshot_path, options.mode)
        table.insert(screenshots, screenshot_path)
        screenshot_cycle(counter + 1)
    end

    screenshot_cycle(1)
end

local function mosaic()
    if not check_magick() then
        msg.error("ImageMagick is not installed or not in PATH. Please install it or set append_magick=true in script options.")
        mp.osd_message("ImageMagick is not installed or not in PATH. Please install it or set append_magick=true in script options.", 5)
        return
    end

    local duration, width, height = get_video_info()
    if not duration or not width or not height then
        msg.error("Failed to get video information.")
        return
    end

    local original_time_pos = mp.get_property_number("time-pos")
    if not original_time_pos then
        msg.error("Failed to get time position.")
        return
    end

    msg.info("Running Mosaic Tools with the following options:")
    msg.info("  Rows: " .. options.rows)
    msg.info("  Columns: " .. options.columns)
    msg.info("  Padding: " .. options.padding)
    msg.info("  Format: " .. options.format)
    msg.info("  Video Length: " .. duration)
    msg.info("  Video Width: " .. width)
    msg.info("  Video Height: " .. height)

    local formatted_duration = format_duration(duration)
    local start_time = duration * 0.1
    local end_time = duration * 0.9
    local time_step = (end_time - start_time) / (options.rows * options.columns - 1)
    local image_count = options.rows * options.columns

    mp.osd_message("Creating " .. options.columns .. "x" .. options.rows .. " mosaic of " .. image_count .. " screenshots...", 2)
    msg.info("Creating " .. options.columns .. "x" .. options.rows .. " mosaic of " .. image_count .. " screenshots...")

    mp.set_property("pause", "yes")

    take_screenshots(start_time, time_step, function(screenshots)
        mp.set_property_number("time-pos", original_time_pos)
        mp.set_property("pause", "no")

        if #screenshots > 0 then
            msg.info("Creating mosaic for " .. options.columns .. "x" .. options.rows .. " images...")
            mp.osd_message("Creating mosaic...", 2)

            local filename = mp.get_property("filename")
            local output_dir = get_output_dir()
            local filename = "montago" .. "." .. options.format

            local output_file = output_dir .. "\\" .. filename  -- Use backslashes for Windows paths
            msg.info("Creating image montage: " .. output_file)

            create_mosaic(screenshots, output_file, function(success)
                if success then
                    msg.info("Mosaic created for " .. options.columns .. "x" .. options.rows .. " images at " .. output_file)
                else
                    msg.error("Failed to create mosaic for " .. options.columns .. "x" .. options.rows .. " images...")
                end

                
            end)
        end
    end)
end

mp.add_key_binding("Ctrl+Alt+s", "screenshot", mosaic)