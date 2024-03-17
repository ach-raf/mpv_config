-- cycle_subtitles.lua

local mp = require("mp")

function cycle_subtitles()
    local sid = mp.get_property_number("sid")
    local subtitle_tracks = mp.get_property_native("track-list")

    local subtitle_count = 0
    local foundCurrentTrack = false

    for _, track in ipairs(subtitle_tracks) do
        if track.type == "sub" then
            subtitle_count = subtitle_count + 1

            if track.id == sid then
                foundCurrentTrack = true
            end
        end
    end

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
        local selected_track = subtitle_tracks[sid]
        mp.osd_message(string.format("%d/%d: %s", sid, subtitle_count, selected_track.title))
    end
end

mp.add_key_binding("s", "cycle_subtitles", cycle_subtitles)
