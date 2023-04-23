-- SEX MARKERS BY SSRAZER

local markers = {}

local function on_render()
    local realtime = globalvars.get_real_time()

    for i = 1, #markers do
        if markers[i] == nil then return end
        local hitmark = markers[i]

        local vec = se.world_to_screen(
            vec3_t.new(hitmark.position.x, hitmark.position.y, hitmark.position.z)
        )

        local x = vec.x
        local y = vec.y


        local alpha = math.floor(255 - 255 * (realtime - hitmark.start_time))

        if realtime - hitmark.start_time >= 1 then
            alpha = 0
        end

        if x ~= nil and y ~= nil then
        	renderer.line(vec2_t.new(x - 6, y - 6), vec2_t.new(x - (6 / 4), y - (6 / 4)), color_t.new(105, 90, 205, alpha))
            renderer.line(vec2_t.new(x - 6, y + 6), vec2_t.new(x - (6 / 4), y + (6 / 4)), color_t.new(105, 90, 205, alpha))
            renderer.line(vec2_t.new(x + 6, y - 6), vec2_t.new(x + (6 / 4), y - (6 / 4)), color_t.new(105, 90, 205, alpha))
            renderer.line(vec2_t.new(x + 6, y + 6), vec2_t.new(x + (6 / 4), y + (6 / 4)), color_t.new(105, 90, 205, alpha))
        end

        if realtime - hitmark.start_time >= 1 then
            table.remove(hitmark, i)
        end
    end
end

local function on_shot(e)
    if e.result ~= 'hit' then return end
    local time = globalvars.get_real_time()

    table.insert(markers, {
        position = { x = e.aim_point.x, y = e.aim_point.y, z = e.aim_point.z },
        start_time = time + 2,
        frame_time = time
    })
end

client.register_callback('paint', on_render)
client.register_callback('shot_fired', on_shot)
