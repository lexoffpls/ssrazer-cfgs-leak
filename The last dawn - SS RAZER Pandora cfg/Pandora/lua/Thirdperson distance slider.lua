local dist_ref = ui.add_slider("Thirdperson distance", 0, 200)
local get_cam_idealdist = cvar.find_var("cam_idealdist")

callbacks.register("paint", function()
   get_cam_idealdist:set_value_int(dist_ref:get())
end)