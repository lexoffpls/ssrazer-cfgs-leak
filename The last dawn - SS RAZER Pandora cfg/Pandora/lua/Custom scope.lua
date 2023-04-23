local entity_get_client_entity = entity_list.get_client_entity
local alpha = 0

local scope_selection_combo = ui.get("Visuals", "General", "Other group", "Scope effect type")

local speed_slider = ui.add_slider("Fade time", 0, 1000)
speed_slider:set(150)

local scope_color_label = ui.add_label("Scope color")
local scope_color = ui.add_cog("dsda", true, false)
scope_color:set_color(color.new(255,255,255,235))

local scope_width = ui.add_slider("Scope width", 0, 500)
local scope_height = ui.add_slider("Scope height", 0, 500)
scope_width:set(100)
scope_height:set(100)

local scope_padding = ui.add_slider("Scope padding", 0, 250)
scope_padding:set(15)

-- maybe do this in a different function, this is just an example though
function on_paint()
    if scope_selection_combo:get() > 0 then
        return
    end

    -- Get screen size to render in the middle
    local screen_size_x, screen_size_y = render.get_screen()
    local screen_center = vector2d.new(screen_size_x / 2, screen_size_y / 2)
 
    -- Local player check
    local_player = entity_get_client_entity(engine.get_local_player())
 
    -- Checks to see if client is in game, else return
    if not engine.in_game() then
        return
    end
 
    -- Local player check to see if local player is a thing
    if local_player == nil then
        return
    end
    
    -- Health check to see if you are alive
    if local_player:get_prop("DT_BasePlayer", "m_iHealth"):get_int() <= 0 then
        return
    end

    -- Reach full alpha in ~100ms
    local multiplier = (1.0 / (speed_slider:get()/1000)) * global_vars.frametime

    -- Health check to see if you are alive
    if local_player:get_prop("DT_CSPlayer", "m_bIsScoped"):get_bool() then
        if alpha < 1.0 then
            alpha = alpha + multiplier
        end
    else
        if alpha > 0.0 then
            alpha = alpha - multiplier
        end
    end

    -- clamp alpha not to go out of bounds
    if alpha >= 1.0 then
        alpha = 1
    end
  
    if alpha <= 0.0 then
        alpha = 0
        return
    end

    local r, g, b, a = scope_color:get_color():r(), scope_color:get_color():g(), scope_color:get_color():b(), scope_color:get_color():a()

    -- top
    local height = scope_height:get()
    pos = vector2d.new(screen_center.x, screen_center.y - height)
    size = vector2d.new(1, height * alpha)
    pos.y = pos.y - (scope_padding:get() - 1)
    render.gradient(pos.x, pos.y, size.x, size.y, color.new(0,0,0,0), color.new(r,g,b,a * alpha), false)

    -- bottom
    pos = vector2d.new(screen_center.x, screen_center.y + (height * ( 1.0 - alpha ) ))
    size = vector2d.new(1, scope_height:get() - ( height * ( 1.0 - alpha ) ))
    pos.y = pos.y + scope_padding:get()
    render.gradient(pos.x, pos.y, size.x, size.y, color.new(r,g,b,a * alpha), color.new(0,0,0,0), false)

    local width = scope_width:get()

    -- left
    pos = vector2d.new(screen_center.x - width, screen_center.y)
    size = vector2d.new(width * alpha, 1)
    pos.x = pos.x - (scope_padding:get() - 1)
    render.gradient(pos.x, pos.y, size.x, size.y, color.new(0,0,0,0), color.new(r,g,b,a * alpha), true)

    -- right
    pos = vector2d.new(screen_center.x + (width* ( 1.0 - alpha ) ), screen_center.y)
    size = vector2d.new(width - ( width * ( 1.0 - alpha ) ), 1)
    pos.x = pos.x + scope_padding:get()
    render.gradient(pos.x, pos.y, size.x, size.y, color.new(r,g,b,a * alpha), color.new(0,0,0,0), true)
end

callbacks.register("paint", on_paint)