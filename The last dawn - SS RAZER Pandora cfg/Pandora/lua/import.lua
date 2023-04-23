-- https://www.youtube.com/watch?v=DWzXw1_Rne8

local exported_data = {
    -- data
}

local import_colors = ui.add_button("Import colors")
import_colors:add_callback(function()
    for i = 1, #exported_data do 
        local new_color = color.new(exported_data[i].color.r, exported_data[i].color.g, exported_data[i].color.b, exported_data[i].color.a)
        ui.get(exported_data[i].path[1], exported_data[i].path[2], exported_data[i].path[3], exported_data[i].path[4]):set_color(new_color)
    end

    print("imported "..tostring(#exported_data).." colors")
end)