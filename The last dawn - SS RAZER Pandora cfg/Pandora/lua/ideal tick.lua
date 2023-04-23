local idealtick = {
    autopeek_state = 0,
    doubletap_state = 0,
    doubletap_key_state = 0,
    freestanding_state = 0,

    active = true
}

local idealtick_combo = ui.add_multi_dropdown("Conditions", { "Freestanding" })
local idealtick_key = ui.add_cog("Ideal tick", false, true)

local get_key_state = function(var)
    local _, state = var:get_key()
    return state
end

local refs = {
    doubletap = ui.get("Rage", "Exploits", "General", "Enabled"),
    doubletap_key = ui.get("Rage", "Exploits", "General", "Double tap key"),
    doubletap_exploit = ui.get("Rage", "Exploits", "General", "Double tap peek exploit"),
    autopeek = ui.get("Misc", "General", "Movement", "Auto peek"),
    autopeek_key = ui.get("Misc", "General", "Movement", "Auto peek key"),
    freestanding_key = ui.get("Rage", "Anti-aim", "General", "Freestanding key")
}

idealtick.run = function()
    if idealtick_key:get_key() then
        if idealtick.active then
            idealtick.autopeek_state = refs.autopeek_key:get_key()
            idealtick.doubletap_key_state = refs.doubletap_key:get_key()
            idealtick.freestanding_state = refs.freestanding_key:get_key()

            idealtick.active = false
        end

        if idealtick_combo:get("Freestanding") then
            refs.freestanding_key:set_key(true)
        end

        refs.doubletap:set(true)
        refs.doubletap_exploit:set(true)

        refs.doubletap_key:set_key(true)
        refs.autopeek_key:set_key(true)

    else
        if not idealtick.active then
            refs.autopeek_key:set_key(idealtick.autopeek_state)
            refs.doubletap_key:set_key(idealtick.doubletap_key_state)
            refs.freestanding_key:set_key(idealtick.freestanding_state)

            idealtick.active = true
        end
    end
end

callbacks.register("paint", idealtick.run)