local r_aspectratio = cvar.r_aspectratio

local default_value = r_aspectratio:get_float()

local function set_aspect_ratio(multiplier)
    local screen_width,screen_height = render.get_screen_size()

    local value = (screen_width * multiplier) / screen_height

    if multiplier == 1 then
        value = 0
    end
    r_aspectratio:set_float(value)
end

-- Menu entries.
local aspect_ratio_slider = gui.add_slider("Aspect ratio", "visuals>misc>various", 1, 200, 1)

function on_paint( )
    local aspect_ratio = aspect_ratio_slider:get_int() * 0.01
    aspect_ratio = 2 - aspect_ratio
    set_aspect_ratio(aspect_ratio)
end

function on_shutdown()
    r_aspectratio:set_float(default_value)
end