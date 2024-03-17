-- cycle_audio.lua

local mp = require("mp")

function update_external_tracks()
    local track_list_track_count = mp.get_property_number("track-list/count")
    local edition_count = mp.get_property_number("edition-list/count")
    local count = #mp.get_property_native("track-list") + edition_count

    if count ~= (track_list_track_count + edition_count) then
        mp.commandv("playlist-remove", "external")
        mp.commandv("loadfile", "://" .. mp.get_property("playlist"))
    end
end

function cycle_audio()
    update_external_tracks()

    local audio_tracks = {}
    for _, track in ipairs(mp.get_property_native("track-list")) do
        if track.type == "audio" then
            table.insert(audio_tracks, track)
        end
    end

    if #audio_tracks < 1 then
        mp.osd_message("No audio tracks")
        return
    end

    local aid = mp.get_property_number("aid")

    if #audio_tracks > 1 then
        aid = (aid % #audio_tracks) + 1
        mp.set_property_number("aid", aid)
    end

    if aid == 0 then
        mp.osd_message("No audio track")
    else
        local selected_track = audio_tracks[aid]
        mp.osd_message(string.format("%d/%d: %s", aid, #audio_tracks, selected_track.title))
    end
end

mp.add_key_binding("a", "cycle_audio", cycle_audio)
