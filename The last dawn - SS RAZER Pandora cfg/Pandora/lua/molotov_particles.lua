local molotov_particles = ui.add_checkbox("molotov particles")

local game_materials = {
    "particle/fire_burning_character/fire_env_fire_depthblend_oriented",
    "particle/fire_burning_character/fire_burning_character",
    "particle/fire_explosion_1/fire_explosion_1_oriented",
    "particle/fire_explosion_1/fire_explosion_1_bright",
    "particle/fire_burning_character/fire_burning_character_depthblend",
    "particle/fire_burning_character/fire_env_fire_depthblend",
}

function on_paint()
    for _, list in ipairs(game_materials) do
        local material = materials.find_material(list)
        -- print(tostring(list))
        if material ~= nil then
            material:set_material_var_flag((1 << 28), molotov_particles:get())
            material:set_material_var_flag((1 << 15), molotov_particles:get())
        end
    end
end

callbacks.register("paint", on_paint);