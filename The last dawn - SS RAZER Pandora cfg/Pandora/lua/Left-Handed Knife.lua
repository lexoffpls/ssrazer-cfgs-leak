local enable = ui.add_checkbox("Left hand on knife")

callbacks.register("paint", function()

    local lp_wep = entity_list.get_client_entity(entity_list.get_client_entity(engine.get_local_player()):get_prop("DT_BaseCombatCharacter", "m_hActiveWeapon"))
    local knife = lp_wep:class_id() == 107

    if enable:get() then
        if knife then
            engine.execute_client_cmd("cl_righthand 0")
        elseif not knife then
            engine.execute_client_cmd("cl_righthand 1")
        end
    end

end)