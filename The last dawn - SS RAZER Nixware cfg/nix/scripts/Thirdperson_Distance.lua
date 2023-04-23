        scale_thirdperson = ui.add_check_box("Thirdperson distance", "scale_thirdperson", false)
        thirdperson_scale = ui.add_slider_int("Thirdperson scale", "thirdperson_scale", 40, 200, 120)

        once_thirdperson = false

        client.register_callback("create_move", function()
        if scale_thirdperson:get_value() then se.get_convar("cam_idealdist"):set_int(scale_thirdperson:get_value() and thirdperson_scale:get_value() or 120) end
        if scale_thirdperson:get_value() and not once_thirdperson then once_thirdperson = not once_thirdperson end
        if not scale_thirdperson:get_value() and once_thirdperson then once_thirdperson = not once_thirdperson; se.get_convar("cam_idealdist"):set_int(120) end
        end) client.register_callback("unload", function() if scale_thirdperson:get_value() then se.get_convar("cam_idealdist"):set_int(120) end end)