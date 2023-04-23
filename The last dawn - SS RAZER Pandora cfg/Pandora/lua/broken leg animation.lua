local slidewalk = ui.get("Misc", "General", "Movement", "Leg movement")
local local_player = entity_list.get_client_entity(engine.get_local_player())
local prop = local_player:get_prop("DT_BasePlayer", "m_flPoseParameter")
local state = true

function on_paint()
    state = not state
    if state then prop:set_int(1) else prop:set_int(0) end
    if state then slidewalk:set(1) else slidewalk:set(2) end end

callbacks.register("paint", on_paint);