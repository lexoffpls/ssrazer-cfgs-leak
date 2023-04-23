local cstrike = {}

cstrike.is_scoped = function(entity)
    if entity then
        local scoped = entity:get_prop("DT_CSPlayer", "m_bIsScoped"):get_int()
        if scoped == 1 then
            return true
        end
    end

    return false
end

local viewmodel_in_scope = ui.add_checkbox("viewmodel in scope")
local viewmodel_fov = ui.add_slider_float("viewmodel fov", 40.0, 80.0)
local viewmodel_x = ui.add_slider_float("viewmodel x", -10.0, 10.0)
local viewmodel_y = ui.add_slider_float("viewmodel y", -10.0, 10.0)
local viewmodel_z = ui.add_slider_float("viewmodel z", -10.0, 10.0)

local on_paint = function()
    cvar.find_var("viewmodel_fov"):set_value_float(viewmodel_fov:get())
    cvar.find_var("viewmodel_offset_x"):set_value_float(viewmodel_x:get())
    cvar.find_var("viewmodel_offset_y"):set_value_float(viewmodel_y:get())
    cvar.find_var("viewmodel_offset_z"):set_value_float(viewmodel_z:get())

    local fov_cs_debug = cvar.find_var("fov_cs_debug")

    if not viewmodel_in_scope:get() then
        fov_cs_debug:set_value_int(0)
        return
    end

    local local_player = entity_list.get_client_entity(engine.get_local_player())
    if not local_player then
        return
    end

    if cstrike.is_scoped(local_player) then
        fov_cs_debug:set_value_int(90)
    else
        fov_cs_debug:set_value_int(0)
    end
end

callbacks.register("paint", on_paint)