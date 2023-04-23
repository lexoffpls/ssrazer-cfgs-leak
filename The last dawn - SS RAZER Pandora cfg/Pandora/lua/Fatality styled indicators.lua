local verdana = render.create_font( "Verdana", 28, 700, font_flags.dropshadow | font_flags.antialias );

local ENABLED_COLOR = color.new( 0, 153, 204 );
local DISABLED_COLOR = color.new( 170, 33, 33 );

local indicators_dropdown = ui.add_multi_dropdown( "Indicators", {
    "Anti-exploit",
    "Double tap",
    "Damage override",
    "Force safety",
    "Fake duck"
} );

local function blend_colors( a, b, multiplier )
    return color.new(
        a:r( ) + ( multiplier * ( b:r( ) - a:r( ) ) ),
        a:g( ) + ( multiplier * ( b:g( ) - a:g( ) ) ),
        a:b( ) + ( multiplier * ( b:b( ) - a:b( ) ) ),
        a:a( ) + ( multiplier * ( b:a( ) - a:a( ) ) )
    );
end

local indicators = { }

local cl_lagcompensation = cvar.find_var( "cl_lagcompensation" );

table.insert( indicators, {
    text = "AX",
    can_draw = function( ) return indicators_dropdown:get( "Anti-exploit" ) and not cl_lagcompensation:get_bool( ) end,
    color = function( ) return ENABLED_COLOR end,
    value = function( ) return -1 end,
    max_value = function( ) return -1 end
} );

local exploits_enabled_checkbox = ui.get( "Rage", "Exploits", "General", "Enabled" );
local double_tap_key = ui.get( "Rage", "Exploits", "General", "Double tap key" );
local fake_duck_key = ui.get( "Rage", "Anti-aim", "Fake-lag", "Fake duck key" );

table.insert( indicators, {
    text = "DT",
    can_draw = function( ) return indicators_dropdown:get( "Double tap" ) and not fake_duck_key:get_key( ) and exploits_enabled_checkbox:get( ) and double_tap_key:get_key( ) end,
    color = function( ) return blend_colors( DISABLED_COLOR, ENABLED_COLOR, ( exploits.process_ticks( ) / 14 ) ) end,
    value = function( ) return exploits.process_ticks( ) end,
    max_value = function( ) return 14 end
} );

local damage_override_key = ui.get( "Rage", "Aimbot", "General", "Minimum damage override key" );

table.insert( indicators, {
    text = "DMG",
    can_draw = function( ) return indicators_dropdown:get( "Damage override" ) and damage_override_key:get_key( ) end,
    color = function( ) return ENABLED_COLOR end,
    value = function( ) return -1 end,
    max_value = function( ) return -1 end
} );

local force_safety_key = ui.get( "Rage", "Aimbot", "General", "Force safety key" );

table.insert( indicators, {
    text = "SP",
    can_draw = function( ) return indicators_dropdown:get( "Force safety" ) and force_safety_key:get_key( ) end,
    color = function( ) return ENABLED_COLOR end,
    value = function( ) return -1 end,
    max_value = function( ) return -1 end
} );

local function get_duck_amount( )
    local local_player_idx = engine.get_local_player( );
    local local_player = entity_list.get_client_entity( local_player_idx );

    return local_player:get_prop( "DT_BasePlayer", "m_flDuckAmount" ):get_float( );
end

table.insert( indicators, {
    text = "FD",
    can_draw = function( ) return indicators_dropdown:get( "Fake duck" ) and fake_duck_key:get_key( ) end,
    color = function( ) return blend_colors( ENABLED_COLOR, DISABLED_COLOR, ( get_duck_amount( ) / 1.0 ) ) end,
    value = function( ) return -1 end,
    max_value = function( ) return -1 end
} );

local screen_width, screen_height = render.get_screen( );
local center_x = ( screen_width / 2 );
local center_y = ( screen_height / 2);

local function on_paint( )
    if not client.is_alive() or not engine.is_connected( ) then
        return
    end

    local count = 0;
    local additonal_y = 0;

    for idx = 1, #indicators do
        local indicator = indicators[ idx ];

        local text_width, text_height = verdana:get_size( indicator.text );
        local y = center_y + ( count * text_height ) + additonal_y + 112;

        if indicator.can_draw( ) then
            local color = indicator.color( );

            verdana:text( 10, y, color, indicator.text );
            
            local value = indicator.value( );
            local max_value = indicator.max_value( );

            if value ~= -1 and max_value ~= -1 then
                render.rectangle_filled( 10, y + text_height, text_width, 4, color.new( 0, 0, 0, 150 ) );

                local value_faction = ( value / max_value );

                render.rectangle_filled( 11, y + text_height + 1, ( text_width * value_faction ) - 2, 2, color );

                additonal_y = additonal_y + 8;
            end

            count = count + 1;
        end
    end
end

local function init( )
    callbacks.register( "paint", on_paint );
end
init( );