local verdana = renderer.setup_font('C:/windows/fonts/verdana.ttf', 11, 144)

local timer = ui.add_slider_int('Time to show', 'timer', 3, 15, 5)

local neutral_color = ui.add_color_edit('Neutral color', 'neutral_color', false, color_t.new(255, 255, 255, 255))
local hit_color = ui.add_color_edit('Hit color', 'hit_color', false, color_t.new(108, 195, 18, 255))
local miss_color = ui.add_color_edit('Miss color', 'miss_color', false, color_t.new(255, 0, 0, 255))

local shots = { }

local hitboxes = {[1] = 'head',[2] = 'chest',[3] = 'stomach',[4] = 'right arm',[5] = 'left arm',[6] = 'right leg',[7] = 'left leg'}

local events = {
    hit = function()
        client.register_callback('player_hurt', function(i)
            local local_player = engine.get_local_player()
            local attacker = engine.get_player_for_user_id(i:get_int('attacker', 0))
            if local_player == attacker then
                local userid = engine.get_player_for_user_id(i:get_int('userid', 0))
                local userid_name = engine.get_player_info(userid).name
                local hitbox = hitboxes[i:get_int('hitgroup', 0)]
                local damage, remaining = i:get_int('dmg_health', 0), i:get_int('health', 0)

                table.insert(shots, 
                {
                    {
                        {'Hit', neutral_color:get_value()},
                        {' ' .. userid_name, hit_color:get_value()},
                        {' in the', neutral_color:get_value()},
                        {' ' .. hitbox, hit_color:get_value()},
                        {' for', neutral_color:get_value()},
                        {' ' .. damage, hit_color:get_value()},
                        {' health (', neutral_color:get_value()},
                        {tostring(remaining), hit_color:get_value()},
                        {' health remained)', neutral_color:get_value()},
                    },
                    globalvars.get_current_time(), 0,
                })
            end
        end)
    end,

    miss = function()
        client.register_callback('shot_fired', function(i)
            if i.result ~= 'hit' and not i.manual then
                local target = i.target_index
                local target_name = engine.get_player_info(target).name
                local hitbox = hitboxes[i.hitbox + 1]
                local result, hitchance = i.result, i.hitchance

                table.insert(shots, 
                {
                    {
                        {'Missed', neutral_color:get_value()},
                        {' ' .. target_name, miss_color:get_value()},
                        {'`s', neutral_color:get_value()},
                        {' ' .. hitbox, miss_color:get_value()},
                        {' due to', neutral_color:get_value()},
                        {' ' .. result, miss_color:get_value()},
                        {' (', neutral_color:get_value()},
                        {tostring(hitchance), miss_color:get_value()},
                        {'% hitchance)', neutral_color:get_value()},
                    },
                    globalvars.get_current_time(), 0,
                })
            end
        end)
    end,    

    round_prestart = function()
        client.register_callback('round_prestart', function()
            shots = { }
        end)
    end,

    disconnected = function()
        client.register_callback('paint', function()
            if engine.is_connected() == false then
                shots = { }
            end
        end)
    end,
}

events.hit()
events.miss()
events.round_prestart()
events.disconnected()

local render = {
    multi_color_string = function(table, font, pos, size, alpha)
        local x = 0
        for i = 1, #table do
            renderer.text(table[i][1], font, vec2_t.new(pos.x+1+x,pos.y+1), size, color_t.new(0, 0, 0, 255*alpha))
            renderer.text(table[i][1], font, vec2_t.new(pos.x+x,pos.y), size, color_t.new(table[i][2].red*255, table[i][2].green*255, table[i][2].blue*255, 255*alpha))
            x = x + renderer.get_text_size(font, size, table[i][1]).x
        end
    end,
    get_multi_color_string_size = function(table, font, size)
        local x = 0
        for i = 1, #table do
            x = x + renderer.get_text_size(font, size, table[i][1]).x
        end
        return x
    end,
}

local main_functions = {
    render_log = function()
        client.register_callback('paint', function()
            local center, count, frames = vec2_t.new(engine.get_screen_size().x/2, engine.get_screen_size().y/1.35), 0, globalvars.get_frame_time()*8
            for i = 1, #shots do
                if globalvars.get_current_time() - shots[i][2] < timer:get_value() then
                    shots[i][3] = shots[i][3] + frames if shots[i][3] > 1 then shots[i][3] = 1 end
                else
                    shots[i][3] = shots[i][3] - frames if shots[i][3] < 0 then shots[i][3] = 0 end
                end
                render.multi_color_string(shots[i][1], verdana, vec2_t.new(center.x - 50+50*(shots[i][3]) - render.get_multi_color_string_size(shots[i][1], verdana, 11)/2, center.y + count*shots[i][3]), 11, shots[i][3])
                count = count + 11*shots[i][3]
            end
        end)
    end,
}

main_functions.render_log()
