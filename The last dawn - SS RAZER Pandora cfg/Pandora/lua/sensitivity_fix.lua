local zoom_sens_ratio = cvar.find_var("zoom_sensitivity_ratio_mouse")
local zoom_sens_ratio_backup = zoom_sens_ratio:get_float()

callbacks.register("paint", function()
	local local_player = entity_list.get_client_entity(engine.get_local_player())
	local scoped = local_player:get_prop("DT_CSPlayer", "m_bIsScoped"):get_int() == 1

	zoom_sens_ratio:set_value_float(scoped and 0.0 or zoom_sens_ratio_backup)
end)