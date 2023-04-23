local displayMaxSpeed = ui.add_dropdown("Display Maxium Speed", {"Disabled", "Bar"})
local interval = 0

local function rgb_health_based(percentage)
    local r = 124*2 - 124 * percentage
    local g = 195 * percentage
    local b = 13
    return r, g, b
end

local function remap(val, newmin, newmax, min, max, clamp)
    min = min or 0
    max = max or 1

    local pct = (val-min)/(max-min)

    if clamp ~= false then
        pct = math.min(1, math.max(0, pct))
    end

    return newmin+(newmax-newmin)*pct
end

local function rectangle_outline(x, y, w, h, r, g, b, a, s)
    s = s or 1
    render.rectangle(x, y, w, s, color.new(r, g, b, a)) -- top
    render.rectangle(x, y+h-s, w, s, color.new(r, g, b, a)) -- bottom
    render.rectangle(x, y+s, s, h-s*2, color.new(r, g, b, a)) -- left
    render.rectangle(x+w-s, y+s, s, h-s*2, color.new(r, g, b, a)) -- right
end

local function drawBar(modifier, r, g, b, a, text)
    local text_width = 95
    local sw, sh = render.get_screen()
    local x, y = sw/2-text_width, sh*0.35

    if a > 0.7 then
        render.rectangle(x+13, y+11, 8, 20, color.new(16, 16, 16, 255*a))
    end

    render.text(x+8, y+3, string.format("%s %.f", text, modifier * 100.0), color.new(255, 255, 255, 255*a))

    local rx, ry, rw, rh = x+8, y+3+17, text_width, 12
    rectangle_outline(rx, ry, rw, rh, 0, 0, 0, 255*a, 1)
    render.rectangle_filled(rx+1, ry+1, rw-2, rh-2, color.new(16, 16, 16, 180*a))
    render.rectangle_filled(rx+1, ry+1, math.floor((rw-2)*modifier), rh-2, color.new(r, g, b, 180*a))
end

callbacks.register("paint", function()
    local lp = entity_list.get_client_entity(engine.get_local_player())
    if not client.is_alive() then return end

    local modifier = lp:get_prop("DT_CSPlayer", "m_flVelocityModifier"):get_float()
    if modifier == 1 then return end

    local r, g, b = rgb_health_based(modifier)
    local a = remap(modifier, 1, 0, 0.85, 1)

    if displayMaxSpeed:get() == 1 then
        drawBar(modifier, r, g, b, a, "Slowed down")
    end
end)