local small_fonts = render.create_font( "Small Fonts", 9, 400, font_flags.dropshadow );
local world_hitmarker_dmg = ui.add_checkbox( "World hitmarker damage" );

local markers = { }

function on_paint( )
    if not world_hitmarker_dmg:get( ) then
        return
    end

    local step = 255.0 / 1.0 * global_vars.frametime;
    local step_move = 30.0 / 1.5 * global_vars.frametime;
    local multiplicator = 0.3;

    for idx = 1, #markers do
        local marker = markers[ idx ];

        if marker == nil then
            return
        end

        marker.moved = marker.moved - step_move;

        if marker.create_time + 0.5 <= global_vars.curtime then
            marker.alpha = marker.alpha - step;
        end

        if marker.alpha > 0 then
            local screen_position = vector2d.new( 0, 0 );

            if render.world_to_screen( marker.world_position, screen_position ) then
                small_fonts:text( screen_position.x + 8, screen_position.y - 12 + marker.moved, color.new( 255, 0, 0, marker.alpha ), "-" .. marker.dmg );
            end
        else
            table.remove( markers, idx );
        end
    end
end

function on_hitmarker( damage, position )
    table.insert( markers, {
        dmg = damage,
        world_position = vector.new( position.x, position.y, position.z ), -- lua is dumb, can't just pass position here.
        create_time = global_vars.curtime,
        moved = 0.0,
        alpha = 255.0
    } );
end

callbacks.register( "on_hitmarker", on_hitmarker );
callbacks.register( "paint", on_paint );