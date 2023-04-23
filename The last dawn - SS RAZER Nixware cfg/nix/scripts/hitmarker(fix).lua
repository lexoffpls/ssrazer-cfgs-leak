local hitmark_font = renderer.setup_font('c:/windows/fonts/verdana.ttf', 11, 0)
local is_enabled = ui.add_check_box('Hitmarker', 'vis_shotmarkers_enable', false)

local shots = {}

local function draw_shot(x, y, alpha, damage)
    if damage > 0 then
    renderer.text( "-".. tostring(damage) .. "HP", hitmark_font, vec2_t.new(x - 10, y), 11, color_t.new(255,255,255,255))
   end
end

local function morgenhit_render()
    if not is_enabled:get_value() then return end

    local realtime = globalvars.get_real_time()

    for i = 1, #shots do
        if shots[i] == nil then return end
        local shot = shots[i]

        local vec = se.world_to_screen(
            vec3_t.new(shot.position.x, shot.position.y, shot.position.z)
        )

        local x = vec.x
        local y = vec.y

        local alpha = math.floor(255 - 255 * (realtime - shot.start_time))

        if realtime - shot.start_time >= 1 then
            alpha = 0
        end

        if x ~= nil and y ~= nil then
            draw_shot(x - 5, y - 5, alpha, shot.damage, shot.result)
        end

        shot.position.z = shot.position.z + (realtime - shot.frame_time) * 50
        shot.frame_time = realtime

        if realtime - shot.start_time >= 1 then
            table.remove(shots, i)
        end
    end
end

local function morgenhit_shot(e)
    local time = globalvars.get_real_time()

    table.insert(shots, {
        position = { x = e.aim_point.x, y = e.aim_point.y, z = e.aim_point.z },
        damage = e.server_damage,
        start_time = time,
        frame_time = time
    })
end

client.register_callback('paint', morgenhit_render)
client.register_callback('shot_fired', morgenhit_shot)

