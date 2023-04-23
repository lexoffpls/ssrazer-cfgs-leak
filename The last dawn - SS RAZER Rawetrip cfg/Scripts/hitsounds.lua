--[[
    Custom Hitsounds

    Allow files edit required.

    put your shit in csgo/sound
    .wav only
]]
local hitsoundsPath = engine.get_gamepath():gsub("\\", "/").."/sound"
local hitsounds = {}
console.print("\n"..hitsoundsPath)
for _, v in next, file.get_files_from_dir(hitsoundsPath) do
    if v:find(".wav") == nil then
        goto continue
    end
    local name = v:gsub("(.+\\)", ""):gsub("(%..+)", "")
    table.insert(hitsounds, name)
    ::continue::
end

local selected = ui.add_combobox("Sound", hitsounds)
local nameSelected = hitsounds[selected:get()+1]

cheat.push_callback("on_paint", function(event)
    selected:set_callback(function()
        nameSelected = hitsounds[selected:get()+1]
        console.print("\n"..nameSelected)
    end)
end)

cheat.push_callback("on_event", function(event)
    if (event:get_name() == "player_hurt") then
        local attacker = event:get_int("attacker")
        local attacker_idx = engine.get_player_for_user_id(attacker)
        local lp_idx = engine.get_local_player_index()
        if attacker_idx == lp_idx then
            console.execute_client_cmd(("play %s"):format(nameSelected)) 
        end
    end
end)