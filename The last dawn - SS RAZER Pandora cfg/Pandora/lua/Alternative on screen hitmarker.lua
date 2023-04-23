local size_ref = ui.add_slider("Line Size", 1, 10)
local dist_ref = ui.add_slider("Line Distance", 0, 10)
local fade_ref = ui.add_slider_float("Fade Time", 0.3, 1.5)

local disable_time = 0
local hitmarker_time = 0
local screen_x, screen_y = render.get_screen()

callbacks.register("player_hurt", function(event)
    local attacker = event:get_int("attacker")
    local attacker_to_player = engine.get_player_for_user_id(attacker)
    local local_index = engine.get_local_player()

    local get_timer = fade_ref:get()

    if attacker_to_player == local_index then
        disable_time = global_vars.realtime + get_timer
        hitmarker_time = get_timer
    end

end)

callbacks.register("paint",function()
    local get_size = size_ref:get()
    local get_distance = dist_ref:get()
 
    if disable_time < global_vars.realtime then return end
    local a = get_distance
    local p = 255 * (disable_time - global_vars.realtime) / hitmarker_time
    local b = a + get_size
    local color = color.new(200, 200, 200, math.floor(p))
 
    render.line(screen_x / 2 - b, screen_y / 2 - b, screen_x / 2 - a, screen_y / 2 - a, color) -- left upper
    render.line(screen_x / 2 - b, screen_y / 2 + b, screen_x / 2 - a, screen_y / 2 + a, color) -- left down
    render.line(screen_x / 2 + b, screen_y / 2 + b, screen_x / 2 + a, screen_y / 2 + a, color) -- right down
    render.line(screen_x / 2 + b, screen_y / 2 - b, screen_x / 2 + a, screen_y / 2 - a, color) -- right upper

end)