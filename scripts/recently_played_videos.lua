-- Configuration
local log_path = "F:\\Shows\\played_videos.log"

-- Function to write current video info to the log
function write_played_video()
    local title = mp.get_property("media-title"):gsub("\"", "")
    local path = mp.get_property("path")

    if title and path then
        local log_entry = string.format("[%s] \"%s\" | %s", os.date("%d/%m/%y %X"), title, path)

        -- Read existing log entries
        local existing_log = {}
        local f = io.open(log_path, "r")

        if f then
            for line in f:lines() do
                table.insert(existing_log, line)
            end
            f:close()
        end

        -- Prepend the new entry to the log
        table.insert(existing_log, 1, log_entry)

        -- Rewrite the entire log file
        f = io.open(log_path, "w+")

        if f then
            for _, entry in ipairs(existing_log) do
                f:write(entry .. "\n")
            end
            f:close()
            print("Current video logged to the top of " .. log_path)
        else
            print("Failed to open log file for writing.")
        end
    else
        print("Failed to retrieve video information.")
    end
end

-- Function to handle the "file-loaded" event
function on_file_loaded()
    write_played_video()
end

-- Register the event handler
mp.register_event("file-loaded", on_file_loaded)
