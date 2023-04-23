local references = {
    { ui.get("Rage", "Anti-aim", "General", "Freestanding key"), "Freestanding" },
    { ui.get("Rage", "Anti-aim", "Fake-lag", "Fake duck key"), "Fake duck" },
    { ui.get("Rage", "Exploits", "General", "Double tap key"), "Double tap" },
    { ui.get("Rage", "Exploits", "General", "Hide shots key"), "Hide shots" },
    { ui.get("Rage", "Aimbot", "General", "Roll resolver"), "Roll resolver" }
}
local offset = ui.add_slider("Offset", -200, 200)
local color = ui.add_cog("Color", true, false)
local scr_x, scr_y = render.get_screen()
scr_x, scr_y = scr_x/2, scr_y/2
callbacks.register("paint", function()
    local num = 0
    for i=1, #references do 
        local state, condition = references[i][1]:get_key()
        if state and condition ~= 2 then 
            local offset_x, offset_y = render.get_text_size(references[i][2])
            render.text(scr_x-(offset_x/2), (scr_y-(offset_y/2)-offset:get())-(num*offset_y), references[i][2], color:get_color())
            num = num+1
        end
    end
end)