local executecommands = ui.add_button("Exec Commands")
executecommands:add_callback(function()
    engine.execute_client_cmd("mp_roundtime 99999999999;mp_roundtime_hostage 999999999; mp_roundtime_defuse 9999999999;mp_warmup_end; sv_cheats 1; bot_stop 1;bot_freeze 1;mp_autoteambalance 0;mp_limitteams 100;mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_freezetime 0; endround;mp_buytime 10000000;mp_buy_anywhere 1")
end)