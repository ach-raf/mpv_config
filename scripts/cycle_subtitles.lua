-- cycle_subtitles.lua

local mp = require("mp")

local function print_properties(obj)
    for key, value in pairs(obj) do
        print(tostring(key) .. ": " .. tostring(value))
    end
end

function cycle_subtitles()
    local subtitle_tracks = mp.get_property_native("track-list")
    local cleaned_subtitle_tracks = {}
    local subtitle_count = 0
    local sid = mp.get_property_number("sid")
    local foundCurrentTrack = false

    -- Filter out non-subtitle tracks
    for _, track in ipairs(subtitle_tracks) do
        if track.type == "sub" then
            table.insert(cleaned_subtitle_tracks, track)
            subtitle_count = subtitle_count + 1

            if track.id == sid then
                foundCurrentTrack = true
            end
        end
    end

    -- Update track list with only subtitle tracks
    mp.set_property_native("track-list", cleaned_subtitle_tracks)

    if subtitle_count < 1 then
        mp.osd_message("No subtitles")
        return
    end

    if not foundCurrentTrack then
        sid = 0
    end

    sid = sid % subtitle_count + 1
    mp.set_property_number("sid", sid)

    if sid == 0 then
        mp.osd_message("No subtitle")
    else
        local selected_track = cleaned_subtitle_tracks[sid]
        if selected_track.type ~= "sub" then
            mp.osd_message("No subtitle")
            return
        end
        if selected_track.title == nil then
            selected_track.title = ""
        end

        mp.osd_message(string.format("%d/%d: %s", sid, subtitle_count, selected_track.title .. " - " .. (selected_track.lang or "unknown")))
    end
end


mp.add_key_binding("s", "cycle_subtitles", cycle_subtitles)
