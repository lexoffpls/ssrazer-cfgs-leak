-- https://www.youtube.com/watch?v=DWzXw1_Rne8

local color_refs = {
    -- visuals / general / main group
    { path = {"Visuals", "General", "Main group", "Dormant color picker " } },
    { path = {"Visuals", "General", "Main group", "POV arrows color" } },
    { path = {"Visuals", "General", "Main group", "Health color override color" } },
    { path = {"Visuals", "General", "Main group", "Name color" } },
    { path = {"Visuals", "General", "Main group", "Skeleton color" } },
    { path = {"Visuals", "General", "Main group", "Ammo color" } },
    { path = {"Visuals", "General", "Main group", "Weapon color" } },
    { path = {"Visuals", "General", "Main group", "Weapon icon color" } },
    { path = {"Visuals", "General", "Main group", "Glow color" } },
    { path = {"Visuals", "General", "Main group", "Dropped weapons color" } },

    -- visuals / general / other group
    { path = {"Visuals", "General", "Other group", "Penetration crosshair pen color" } },
    { path = {"Visuals", "General", "Other group", "Penetration crosshair nopen color" } },
    { path = {"Visuals", "General", "Other group", "Target capsules color" } },
    { path = {"Visuals", "General", "Other group", "Grenade prediction color" } },
    { path = {"Visuals", "General", "Other group", "Grenade proximity warning color" } },
    { path = {"Visuals", "General", "Other group", "World color" } },
    { path = {"Visuals", "General", "Other group", "Server bullet impacts color" } },
    { path = {"Visuals", "General", "Other group", "Client bullet impacts color" } },
    { path = {"Visuals", "General", "Other group", "Local bullet tracer color" } },
    { path = {"Visuals", "General", "Other group", "Local bullet tracer glow color" } },
    { path = {"Visuals", "General", "Other group", "Enemy bullet tracer color" } },
    { path = {"Visuals", "General", "Other group", "Enemy bullet tracer glow color" } },

    -- visuals / models / local chams
    { path = {"Visuals", "Models", "Local chams", "Local chams color" } },
    { path = {"Visuals", "Models", "Local chams", "Local overlay color" } },
    { path = {"Visuals", "Models", "Local chams", "Desync chams color" } },
    { path = {"Visuals", "Models", "Local chams", "Attachment chams color" } },
    { path = {"Visuals", "Models", "Local chams", "Hand chams color" } },
    { path = {"Visuals", "Models", "Local chams", "Hand overlay color" } },
    { path = {"Visuals", "Models", "Local chams", "Weapon chams color" } },
    { path = {"Visuals", "Models", "Local chams", "Weapon overlay color" } },
    { path = {"Visuals", "Models", "Local chams", "Local glow color" } },

    -- visuals / models / enemy chams
    { path = {"Visuals", "Models", "Enemy chams", "Visible chams color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Behind wall chams color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Enemy overlay color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Backtrack chams color2" } },
    { path = {"Visuals", "Models", "Enemy chams", "Backtrack chams color1" } },
    { path = {"Visuals", "Models", "Enemy chams", "On-Shot record chams color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Backtrack overlay color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Target chams color" } },
    { path = {"Visuals", "Models", "Enemy chams", "Target chams overlay color" } },

    -- visuals / models / other
    { path = {"Visuals", "Models", "Other", "Local skeleton color" } },

    -- misc / general / movement
    { path = {"Misc", "General", "Movement", "Auto peek key"} },

    -- profile / general / global settings
    { path = {"Profile", "General", "Global settings", "Menu accent color"} }
}

local export_colors = ui.add_button("Export colors")
export_colors:add_callback(function()
    print("local exported_data = {")

    for i = 1, #color_refs do 
        local color = ui.get(color_refs[i].path[1], color_refs[i].path[2], color_refs[i].path[3], color_refs[i].path[4]):get_color()
        
        print("{ path = {'"..tostring(color_refs[i].path[1]).."', '"..tostring(color_refs[i].path[2]).."', '"..tostring(color_refs[i].path[3]).."', '"..tostring(color_refs[i].path[4]).."'}, color = { r = "..tostring(color:r())..", g = "..tostring(color:g())..", b = "..tostring(color:b())..", a = "..tostring(color:a()).." } },")
    end

    print("}\n")

    print("exported "..tostring(#color_refs).." colors")
end)