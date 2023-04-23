-- menu elements.
local disable_lc_checkbox = ui.add_checkbox( "Disable lag compensation" );

-- convars.
local cl_lagcompensation = cvar.find_var( "cl_lagcompensation" );

-- constants.
local TEAM_TERRORIST = 2;
local TEAM_CT = 3;

local function get_player_team( player )
    local m_iTeamNum = player:get_prop( "DT_BaseEntity", "m_iTeamNum" );

    return m_iTeamNum:get_int( );
end

-- https://github.com/perilouswithadollarsign/cstrike15_src/blob/f82112a2388b841d72cb62ca48ab1846dfcc11c8/game/shared/cstrike15/cs_gamerules.cpp#L15238
local function IsConnectedUserInfoChangeAllowed( player )
    local team_num = get_player_team( player );

    if team_num == TEAM_TERRORIST or team_num == TEAM_CT then
        return false;
    end

    return true;
end

-- cache.
local previous_dlc_state = disable_lc_checkbox:get( );

-- team swapping.
local changing_from_team = false;
local previous_team_num = -1;
local team_swap_time = -1;

local function on_paint( )
    -- get the local player's entity index.
    local local_player_idx = engine.get_local_player( );

    -- get the local player.
    local local_player = entity_list.get_client_entity( local_player_idx );

    -- will the server acknowledge our changes to cl_lagcompensation?
    if not engine.is_connected( ) or IsConnectedUserInfoChangeAllowed( local_player ) then
        -- update cl_lagcompensation accordingly.
        cl_lagcompensation:set_value_int( disable_lc_checkbox:get( ) and 0 or 1 );

        -- if we were on a team previously, we need to join that team again.
        if changing_from_team and global_vars.curtime > team_swap_time then
            -- join the team we were previously on.
            engine.execute_client_cmd( "jointeam " .. tostring( previous_team_num ) .. " 1" );

            -- we're no longer waiting to join our previous team.
            changing_from_team = false;
        end
    else
        -- have we clicked the checkbox while we were unable to change cl_lagcompensation?
        if disable_lc_checkbox:get( ) ~= previous_dlc_state then
            -- keep track of what team we're currently on.
            previous_team_num = get_player_team( local_player );

            -- join the spectator team.
            engine.execute_client_cmd( "spectate" );

            -- wait a bit before joining our team again so we don't get kicked for
            -- executing too many commands.
            changing_from_team = true;
            team_swap_time = global_vars.curtime + 1.5;

            -- cache the value of disable_lc_checkbox:get( ).
            previous_dlc_state = disable_lc_checkbox:get( );
        end
    end
end

-- init.
local function init( )
    callbacks.register( "paint", on_paint );
end
init( );