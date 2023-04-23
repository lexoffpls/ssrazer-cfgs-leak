--localiser
local ui_add_checkbox, ui_get, color_new, render_get_screen, render_text, callbacks_register = ui.add_checkbox, ui.get, color.new, render.get_screen, render.text, callbacks.register
--ui
local roll_indicator = ui_add_checkbox("Roll resolver indicator")
local roll_resolver = ui_get("Rage", "Aimbot", "General", "Roll resolver")
--colours
local color = color_new(255, 255, 255, 255)
--screenx,y
local screen_width, screen_height = render_get_screen( );
local center_x = ( screen_width / 2 );
local center_y = ( screen_height / 2);
local function indicator()
    local roll_resolver_state = roll_resolver:get_key()
    if roll_resolver_state == true then
        render_text(center_x, center_y, "ROLL RESOLVER", color)
    end
end
local function main()
    callbacks_register("paint", indicator)
end
main()