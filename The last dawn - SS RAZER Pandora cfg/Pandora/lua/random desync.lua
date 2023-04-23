local fake_limit = ui.get("Rage", "Anti-aim", "General", "Fake yaw limit")
local inverted_fake_limit = ui.get("Rage", "Anti-aim", "General", "Fake yaw limit")

local inverted_fake_limit_value = inverted_fake_limit:get()

callbacks.register("paint", function()
    
local random = math.random(60)

   if not anti_aim.inverted()

      then fake_limit:set(random)

   end

   if anti_aim.inverted()

      then inverted_fake_limit:set(random)

   end

end)