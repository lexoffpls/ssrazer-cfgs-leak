-- menu elements.
local party_mode_checkbox = ui.add_checkbox( "Party mode" );

-- cvars.
local sv_party_mode = cvar.find_var( "sv_party_mode" );

-- callbacks.
local function on_paint( )
    sv_party_mode:set_value_int( ( party_mode_checkbox:get() and 1 or 0 ) );
end

-- init.
local function init( )
    callbacks.register( "paint", on_paint );
end
init( );