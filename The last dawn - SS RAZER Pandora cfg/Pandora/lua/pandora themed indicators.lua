local verdana = render.create_font("Verdana", 21, 500, font_flags.dropshadow | font_flags.antialias);

local messy_code = function(position, doubletap, hideshots, dmg_override, fakeduck) if doubletap and hideshots then position.y = position.y + 10 end; if doubletap and dmg_override then position.y = position.y + 10 end; if doubletap and fakeduck then position.y = position.y + 8 end; if hideshots then position.y = position.y + 3 end; if hideshots and dmg_override then position.y = position.y + 10 end; if hideshots and fakeduck then position.y = position.y + 7 end; if dmg_override and fakeduck then position.y = position.y + 8 end; if fakeduck then position.y = position.y + 18 end; if doubletap and hideshots and dmg_override then position.y = position.y - 5 end; if doubletap and hideshots and fakeduck then position.y = position.y - 5 end; if doubletap and dmg_override and fakeduck then position.y = position.y - 6 end; if hideshots and dmg_override and fakeduck then position.y = position.y - 5 end; if doubletap and hideshots and dmg_override and fakeduck then position.y = position.y - 1 end; end

local rage_options = {
    { tab = "General", name = "Force safety key", text = "safe" },
    { tab = "Accuracy", name = "Force body-aim key", text = "baim" }
}

local antiaim_options = {
    { tab = "General", name = "Freestanding key", text = "free" },
    { tab = "General", name = "Manual left key", text = "left" },
    { tab = "General", name = "Manual backwards key", text = "back" },
    { tab = "General", name = "Manual right key", text = "right" },
    { tab = "General", name = "Anti-aim invert", text = "invert" }
}

local on_paint = function()
    if not client.is_alive() or not engine.is_connected( ) then
        return
    end

    local position = vector2d.new(0, 525)
    local size = vector2d.new(90, 30)

    local doubletap = ui.get("Rage", "Exploits", "General", "Double tap key"):get_key()
    local hideshots = ui.get("Rage", "Exploits", "General", "Hide shots key"):get_key()
    local dmg_override = ui.get_rage("General", "Minimum damage override key"):get_key()
    local fakeduck = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake duck key"):get_key()

    messy_code(position, doubletap, hideshots, dmg_override, fakeduck)

    local indicator = {}

    for i = 1, #rage_options do
        local option = rage_options[i]

        if ui.get_rage(option.tab, option.name):get_key() then
            indicator[#indicator + 1] = option.text
        end
    end

    for i = 1, #antiaim_options do
        local option = antiaim_options[i]

        if ui.get("Rage", "Anti-aim", option.tab, option.name):get_key() then
            indicator[#indicator + 1] = option.text
        end
    end

    if ui.get("Rage", "Aimbot", "General", "Roll resolver"):get_key() then
        indicator[#indicator + 1] = "roll"
    end

    if #indicator <= 0 then
        return
    end

    local menu_color = ui.get("Profile", "General", "Global settings", "Menu accent color"):get_color()

    local size_alt = (30 * #indicator)
    render.gradient(position.x, position.y + size.y, size.x, size_alt, color.new(0, 0, 0, 200), color.new(77, 77, 77, 0), true)

    if not (doubletap or hideshots or dmg_override or fakeduck) then
        render.gradient(position.x, position.y + size.y + 1, size.x, 1, color.new(menu_color:r(), menu_color:g(), menu_color:b(), 200), color.new(0, 0, 0, 0), true)
    end

    render.gradient(position.x, position.y + size.y + size_alt - 2, size.x, 1, color.new(menu_color:r(), menu_color:g(), menu_color:b(), 200), color.new(0, 0, 0, 0), true)

    for i = 1, #indicator do
        local indicator = indicator[i]

        local text_size_x, text_size_y = verdana:get_size(indicator)
        verdana:text(position.x + 6, position.y + (size.y / 2) - (text_size_y / 2) + (size.y * i) - (not (doubletap or hideshots or dmg_override or fakeduck) and 1 or 2), color.new(255, 255, 255), indicator);
    end
end

callbacks.register("paint", on_paint);