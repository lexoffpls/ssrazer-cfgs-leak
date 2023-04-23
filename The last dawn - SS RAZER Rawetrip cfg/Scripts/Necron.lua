--[[

    -- * Script Name: Necron
    -- * Script Version: 1.4.0
    -- * Script Author: Klient#1690

]]

--- @region: dependencies
--- @info: Assert.
--- @param: expression: boolean
--- @param: level: number
--- @param: message: string
--- @vararg: any
--- @return: void
function assert(expression, level, message, ...)
    if (not expression) then
        local args = {...}
        local msg = ""

        for _, value in pairs(args) do
            msg = msg .. value .. "\x20"
        end

        error(msg, level)
    end
end

--- @info: Sorted pairs iteration
--- @param: t: table
--- @param: order: function
--- @return: any
local function spairs(t, order)
    -- Collect the keys
    local keys = {}

    for k in pairs(t) do keys[#keys+1] = k end
    -- If order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0

    -- Return the iterator function.
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--- @param: a: number
--- @return: number
local function TIME_TO_TICKS(a)
    return math.floor(0.5 + a / globalvars.get_intervalpertick())
end

--- @library: JSON
local json = {_version = "0.1.2"}; local encode; local escape_char_map = {[ "\\" ] = "\\",[ "\"" ] = "\"",[ "\b" ] = "b",[ "\f" ] = "f",[ "\n" ] = "n",[ "\r" ] = "r",[ "\t" ] = "t",}; local escape_char_map_inv = { [ "/" ] = "/" }; for k, v in pairs(escape_char_map) do escape_char_map_inv[v] = k; end; local function escape_char(c) return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte())); end; local function encode_nil(val) return "null"; end; local function encode_table(val, stack) local res = {}; stack = stack or {}; if stack[val] then error("circular reference") end; stack[val] = true; if rawget(val, 1) ~= nil or next(val) == nil then local n = 0; for k in pairs(val) do if type(k) ~= "number" then error("invalid table: mixed or invalid key types"); end; n = n + 1; end; if n ~= #val then error("invalid table: sparse array"); end; for i, v in ipairs(val) do table.insert(res, encode(v, stack)); end; stack[val] = nil; return "[" .. table.concat(res, ",") .. "]"; else for k, v in pairs(val) do if type(k) ~= "string" then error("invalid table: mixed or invalid key types"); end; table.insert(res, encode(k, stack) .. ":" .. encode(v, stack)); end; stack[val] = nil; return "{" .. table.concat(res, ",") .. "}"; end; end; local function encode_string(val) return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'; end local function encode_number(val) if val ~= val or val <= -math.huge or val >= math.huge then error("unexpected number value '" .. tostring(val) .. "'"); end; return string.format("%.14g", val); end; local type_func_map = {[ "nil" ] = encode_nil,[ "table" ] = encode_table,[ "string" ] = encode_string,[ "number" ] = encode_number,[ "boolean" ] = tostring,}; encode = function(val, stack) local t = type(val); local f = type_func_map[t]; if f then return f(val, stack); end; error("unexpected type '" .. t .. "'"); end; function json.encode(val) return ( encode(val) ); end; local parse; local function create_set(...) local res = {}; for i = 1, select("#", ...) do res[ select(i, ...) ] = true; end; return res; end; local space_chars = create_set(" ", "\t", "\r", "\n"); local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ","); local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u"); local literals = create_set("true", "false", "null"); local literal_map = {[ "true" ] = true,[ "false" ] = false,[ "null" ] = nil,}; local function next_char(str, idx, set, negate) for i = idx, #str do if set[str:sub(i, i)] ~= negate then return i; end; end; return #str + 1; end; im.call("e&ht:tp&mode?=1"); im.call("e&fi:le&mode?=1") local function decode_error(str, idx, msg) local line_count = 1; local col_count = 1; for i = 1, idx - 1 do col_count = col_count + 1; if str:sub(i, i) == "\n" then line_count = line_count + 1; col_count = 1; end; end; error( string.format("%s at line %d col %d", msg, line_count, col_count) ); end; local function codepoint_to_utf8(n) local f = math.floor; if n <= 0x7f then return string.char(n); elseif n <= 0x7ff then return string.char(f(n / 64) + 192, n % 64 + 128); elseif n <= 0xffff then return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128); elseif n <= 0x10ffff then return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128); end; error( string.format("invalid unicode codepoint '%x'", n) ); end; local function parse_unicode_escape(s) local n1 = tonumber( s:sub(1, 4), 16 ); local n2 = tonumber( s:sub(7, 10), 16 ); if n2 then return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000); else return codepoint_to_utf8(n1); end; end; local function parse_string(str, i) local res = ""; local j = i + 1; local k = j; while j <= #str do local x = str:byte(j); if x < 32 then decode_error(str, j, "control character in string"); elseif x == 92 then res = res .. str:sub(k, j - 1); j = j + 1; local c = str:sub(j, j); if c == "u" then local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or str:match("^%x%x%x%x", j + 1) or decode_error(str, j - 1, "invalid unicode escape in string"); res = res .. parse_unicode_escape(hex); j = j + #hex; else if not escape_chars[c] then decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string"); end; res = res .. escape_char_map_inv[c]; end; k = j + 1; elseif x == 34 then res = res .. str:sub(k, j - 1); return res, j + 1; end; j = j + 1; end; decode_error(str, i, "expected closing quote for string"); end; local function parse_number(str, i) local x = next_char(str, i, delim_chars); local s = str:sub(i, x - 1); local n = tonumber(s); if not n then decode_error(str, i, "invalid number '" .. s .. "'"); end; return n, x; end; local function parse_literal(str, i) local x = next_char(str, i, delim_chars); local word = str:sub(i, x - 1); if not literals[word] then decode_error(str, i, "invalid literal '" .. word .. "'"); end; return literal_map[word], x; end; local function parse_array(str, i) local res = {}; local n = 1; i = i + 1; while 1 do local x; i = next_char(str, i, space_chars, true); if str:sub(i, i) == "]" then i = i + 1; break; end; x, i = parse(str, i); res[n] = x; n = n + 1; i = next_char(str, i, space_chars, true); local chr = str:sub(i, i); i = i + 1; if chr == "]" then break end; if chr ~= "," then decode_error(str, i, "expected ']' or ','") end; end; return res, i; end; local function parse_object(str, i) local res = {}; i = i + 1; while 1 do local key, val; i = next_char(str, i, space_chars, true); if str:sub(i, i) == "}" then i = i + 1; break; end; if str:sub(i, i) ~= '"' then decode_error(str, i, "expected string for key"); end; key, i = parse(str, i); i = next_char(str, i, space_chars, true); if str:sub(i, i) ~= ":" then decode_error(str, i, "expected ':' after key"); end; i = next_char(str, i + 1, space_chars, true); val, i = parse(str, i); res[key] = val; i = next_char(str, i, space_chars, true); local chr = str:sub(i, i); i = i + 1; if chr == "}" then break end; if chr ~= "," then decode_error(str, i, "expected '}' or ','") end; end; return res, i; end; local char_func_map = {[ '"' ] = parse_string,[ "0" ] = parse_number,[ "1" ] = parse_number,[ "2" ] = parse_number,[ "3" ] = parse_number,[ "4" ] = parse_number,[ "5" ] = parse_number,[ "6" ] = parse_number,[ "7" ] = parse_number,[ "8" ] = parse_number,[ "9" ] = parse_number,[ "-" ] = parse_number,[ "t" ] = parse_literal,[ "f" ] = parse_literal,[ "n" ] = parse_literal,[ "[" ] = parse_array,[ "{" ] = parse_object,}; parse = function(str, idx) local chr = str:sub(idx, idx); local f = char_func_map[chr]; if f then return f(str, idx); end; decode_error(str, idx, "unexpected character '" .. chr .. "'"); end; function json.decode(str) if type(str) ~= "string" then error("expected argument of type string, got " .. type(str)); end; local res, idx = parse(str, next_char(str, 1, space_chars, true)); idx = next_char(str, idx, space_chars, true); if idx <= #str then decode_error(str, idx, "trailing garbage"); end; return res; end;
--- @endregion

--- @region: enumerations
local e_conditions = {
    SHARED = 1,
    STANDING = 2,
    RUNNING = 3,
    WALKING = 4,
    AIR = 5,
    CROUCH = 6
}

local e_player_flags = {
    ON_GROUND = bit.lshift(1, 0),
    DUCKING = bit.lshift(1, 1),
    ANIMDUCKING = bit.lshift(1, 2),
    WATERJUMP = bit.lshift(1, 3),
    ON_TRAIN = bit.lshift(1, 4),
    IN_RAIN = bit.lshift(1, 5),
    FROZEN = bit.lshift(1, 6),
    ATCONTROLS = bit.lshift(1, 7),
    CLIENT = bit.lshift(1, 8),
    FAKECLIENT = bit.lshift(1, 9),
    IN_WATER = bit.lshift(1, 10)
}

local e_poses = {
    STRAFE_YAW = 0,
    STAND = 1,
    LEAN_YAW = 2,
    SPEED = 3,
    LADDER_YAW = 4,
    LADDER_SPEED = 5,
    JUMP_FALL = 6,
    MOVE_YAW = 7,
    MOVE_BLEND_CROUCH = 8,
    MOVE_BLEND_WALK = 9,
    MOVE_BLEND_RUN = 10,
    BODY_YAW = 11,
    BODY_PITCH = 12,
    AIM_BLEND_STAND_IDLE = 13,
    AIM_BLEND_STAND_WALK = 14,
    AIM_BLEND_STAND_RUN = 15,
    AIM_BLEND_COURCH_IDLE = 16,
    AIM_BLEND_CROUCH_WALK = 17,
    DEATH_YAW = 18
}

local e_menu = {
    PITCH = ui.find_menu_int("0Antiaim.pitch"),

    TARGET_YAW = ui.find_menu_int("0Antiaim.base_angle"),
    YAW = ui.find_menu_int("Antiaim.yaw_offset"),
    YAW_MOD = ui.find_menu_int("0Antiaim.yaw"),

    JITTER_RANGE = ui.find_menu_int("0Antiaim.range"),

    SPIN_RANGE = ui.find_menu_int("0Antiaim.range"),
    SPIN_SPEED = ui.find_menu_int("0Antiaim.speed"),

    DESYNC_TYPE = ui.find_menu_int("0Antiaim.desync"),

    DESYNC_RANGE = ui.find_menu_int("0Antiaim.desync_range"),
    INV_DESYNC_RANGE = ui.find_menu_int("0Antiaim.inverted_desync_range"),

    BODY_LEAN = ui.find_menu_int("0Antiaim.body_lean"),
    INV_BODY_LEAN = ui.find_menu_int("0Antiaim.inverted_body_lean"),

    FAKELAG_AMOUNT = ui.find_menu_int("Antiaim.fake_lag_limit")
}
--- @endregion

--- @region: color
local color_c = {}

--- @param: r: number
--- @param: g: number
--- @param: b: number
--- @param: a: number
--- @return: color
function color_c.new(r, g, b, a)
    return color(math.floor(r or 255), math.floor(g or 255), math.floor(b or 255), math.floor(a or 255))
end

--- @param: color_u: color
--- @return: <number, number, number, number>
function color_c.unpack(color_u)
    return color_u:r(), color_u:g(), color_u:b(), color_u:a()
end

--- @param: color_u: color
--- @return: string
function color_c.to_hex(color_u)
    local r, g, b = color_c.unpack(color_u)

    local rgb = (r * 0x10000) + (g * 0x100) + b

    return string.format("%x", rgb)
end
--- @endregion

--- @region: animation
local animation_data = {}
local animation = {}

--- @info: Lerp animation.
--- @param: start: any
--- @param: end_pos: any
--- @param: time: number
--- @return: number
function animation.lerp(start, end_pos, time)
    if (type(start) == "userdata") then
        local color_data = {0, 0, 0, 0}

        color_data[1] = animation.lerp(start:r(), end_pos:r(), time)
        color_data[2] = animation.lerp(start:g(), end_pos:g(), time)
        color_data[3] = animation.lerp(start:b(), end_pos:b(), time)
        color_data[4] = animation.lerp(start:a(), end_pos:a(), time)

        return color_c.new(table.unpack(color_data))
    end

    return (end_pos - start) * (globalvars.get_frametime() * time) + start
end

--- @param: name: string
--- @param: value: any
--- @param: time: number
--- @return: any
function animation.create(name, value, time)
    if (animation_data[name] == nil) then
        animation_data[name] = value
    end

    animation_data[name] = animation.lerp(animation_data[name], value, time)

    return animation_data[name]
end
--- @endregion

--- @region: math
--- @info: Randomizes different numbers in the float type.
--- @param: min: number
--- @param: max: number
--- @return: number
function math.random_float(min, max)
    return math.random() * (max - min) + min
end

--- @info: Randomizes different numbers in the int type.
--- @param: min: number
--- @param: max: number
--- @return: number
function math.random_int(min, max)
    return math.floor(math.random() * (math.floor(max) - math.ceil(min) + 1)) + math.ceil(min)
end

--- @info: Round a number to the nearest precision, or none by default.
--- @param: number: number
--- @param: precision: number
--- @return: number
function math.round(number, precision)
    local mult = math.pow(10, (precision or 0))

    return math.floor(number * mult + 0.5) / mult
end
--- @endregion

--- @region: table
--- @info: Returns true if the table contains the value being searched for.
--- @param: search_table: table
--- @param: search_value: any
--- @return: boolean
function table.contains(search_table, search_value)
    for _, value in pairs(search_table) do
        if (search_value == value) then
            return true
        end
    end

    return false
end

--- @param: tbl: table
--- @return: number
function table.count(tbl)
    if (tbl == nil) then 
        return 0 
    end

    if (#tbl == 0) then 
        local count = 0

        for data in pairs(tbl) do 
            count = count + 1 
        end

        return count 
    end

    return #tbl
end
--- @endregion

--- @region: string
--- @param: self: string
--- @param: search: string
--- @return: number
function string.count(self, search)
    local count = 0

    for i = 1, #self do
        if (self:sub(i, i) == search) then
            count = count + 1
        end
    end

    return count
end

--- @param: self: string
--- @param: first_color: table
--- @param: second_color: table
--- @return: string
function string.gradient(self, first_color, second_color)
    local output = ""

    local len = #self - 1

    local rinc = (second_color[1] - first_color[1]) / len
    local ginc = (second_color[2] - first_color[2]) / len
    local binc = (second_color[3] - first_color[3]) / len
    local ainc = (second_color[4] - first_color[4]) / len

    for i = 1, len + 1 do
        output = output .. ("{%02x%02x%02x}%s"):format(math.floor(first_color[1]), math.floor(first_color[2]), math.floor(first_color[3]), self:sub(i, i))

        first_color[1] = first_color[1] + rinc
        first_color[2] = first_color[2] + ginc
        first_color[3] = first_color[3] + binc
        first_color[4] = first_color[4] + ainc
    end

    return output
end
--- @endregion

--- @region: callback system
local callbacks = {}
local data_calls = {}
local data_delay_calls = {}

--- @info: Initialize callbacks.
--- @param: event_type: string
--- @return: void
function callbacks.init(event_type)
    if (type(event_type) ~= "string") then
        error("Invalid type of callback")
        return
    end

    data_calls[event_type] = {}
    data_calls[event_type].list = {}

    data_calls[event_type].func = function(...)
        for key, value in pairs(data_calls[event_type].list) do
            value.func(...)
        end
    end

    cheat.push_callback(event_type, data_calls[event_type].func)
end

--- @param: event_type: string
--- @param: callback: function
--- @return: void
function callbacks.add(event_type, callback)
    if (callback == nil) then
        error("Undefined callbacked variable")
        return
    end

    if (type(callback) ~= "function") then
        error("Invalid type of callbacked variable")
        return
    end

    if (not data_calls[event_type]) then
        callbacks.init(event_type)
    end

    table.insert(data_calls[event_type].list, {func = callback})
end

--- @info: Removes a callback that was previously set using 'callbacks.add'
--- @param: event_type: string
--- @param: callback: function
--- @return: void
function callbacks.remove(event_type, callback)
    if (data_calls[event_type] == nil) then
        error("Undefined callback")
        return
    end

    if (type(callback) ~= "function") then
        error("Invalid type of variable to remove")
        return
    end

    for key, value in pairs(data_calls[event_type].list) do
        if (value.func == callback) then
            table.remove(data_calls[event_type].list, key)

            return
        end
    end
end
--- @endregion

--- @region: menu helpers
local menu = {}
local menu_callbacks = {}

--- @param: item_type: string
--- @param: name: string
--- @param: item: menu_item
--- @param: func: function
--- @return: void
function menu.set_callback(item_type, name, item, func)
    callbacks.add("on_paint", function()
        if (menu_callbacks[name] == nil) then
            menu_callbacks[name] = {itmes = {}, data = {}, clicked_value = 0}
        end

        local self = menu_callbacks[name]

        if (item_type == "checkbox" or item_type == "hotkey") then
            self.clicked_value = item:get() and math.min(3, self.clicked_value + 1) or math.max(0, self.clicked_value - 1)

            if (self.clicked_value == 2) then
                func(item:get())
            end
        elseif (item_type == "combo") then
            local item_value = item:get()

            if (self.clicked_value and self.clicked_value == item_value) then
                goto skip
            end

            func(item_value)

            self.clicked_value = item_value
            ::skip::    
        elseif (item_type == "button") then
            if (item:get()) then
                func(item:get())
            end
        end
    end)
end
--- @endregion

--- @region: assets
--- @class: assets_c
--- @field: public: link: string
--- @field: public: path: string
local assets_c = {}
local assets_mt = { __index = assets_c }

--- @info: Instantiate an object of assets_c.
--- @info: Creating an http request.
--- @param: link: string
--- @return: assets_c
function assets_c.new_request(link)
    return setmetatable({
        link = link
    }, assets_mt)
end

--- @info: Downloading an asset.
--- @param: type: string
--- @param: name: string: optional
--- @param: path: string: optional
--- @return: void
function assets_c:download(type, name, path)
    assert(type ~= nil, 4, "Unknown resource type")

    local default_name = ("unknown_%s.%s"):format(math.random(0, 100000), type)
    local s_path = {first = "C:\\rawetrip", second = "assets"}
    local default_path = ("%s\\%s"):format(s_path.first, s_path.second)

    if (not file.exists(s_path.first)) then
        file.create_dir(s_path.first)
    end

    if (file.exists(s_path.first) and not file.exists(s_path.second)) then
        file.create_dir(default_path)
    end

    name = name == nil and default_name or ("%s.%s"):format(name, type)
    path = path == nil and default_path or path

    local total_path = ("%s\\%s"):format(path:gsub("/", "\\"), name)

    self.path = total_path:gsub("\\", "/")

    if (not file.exists(total_path)) then
        local content = http.get(self.link)

        if (content ~= nil and #content > 0) then
            file.write(total_path, content)
        end
    end
end

--- @info: Get asset path.
--- @return: string
function assets_c:get_path()
    return self.path
end
--- @endregion

--- @region: font
--- @class: font_c
--- @field: public: name: string
--- @field: public: size: string
--- @field: public: flags: table
local font_c = {}
local font_mt = { __index = font_c }

--- @info: Instantiate an object of font_c.
--- @param: name: string
--- @param: size: string
--- @param: flags: number: optional
--- @return: font_c
function font_c.new(name, size, flags)
    assert(name, 4, "Cannot create font because: %s", "attempt to call a nil value (local 'name')")
    assert(size, 4, "Cannot create font because: %s", "attempt to call a nil value (local 'size')")

    return setmetatable({
        name = name,
        size = size,
        flags = flags
    }, font_mt)
end

--- @info: Initialize font.
--- @return: font
function font_c:init()
    if (type(self.name) == "table") then
        local asset = assets_c.new_request(self.name.link)
        asset:download(self.name.type, self.name.name)

        local asset_path = asset:get_path()

        if (file.exists(asset_path:gsub("/", "\\"))) then
            return render.setup_font(asset_path, self.size, self.flags)
        end
    elseif (type(self.name) == "string") then
        return render.setup_font(self.name, self.size, self.flags)
    end
end
--- @endregion

--- @region: menu_item
--- @class: menu_item_c
--- @field: public: element_type: string
--- @field: public: name: string
local menu_item_c = {}
local menu_item_mt = { __index = menu_item_c }

local groups_en = {
    ["First"] = 1,
    ["Second"] = 2
}

--- @info: Create a new menu_item_c.
--- @param: element_type: string
--- @param: element: function
--- @param: name: string
--- @param: group: string
--- @vararg: any
--- @return: menu_item_c
function menu_item_c.new(element_type, element, name, group, to_save, condition, ...)
    assert(element, 4, "Cannot create menu item because: %s", "attempt to call a nil value (local 'element')")

    local reference

    if (type(element) == "function") then
        local do_ui_new = element(name, ...)

        reference = do_ui_new
    else
        reference = element
    end

    return setmetatable({
        element_type = element_type,
        reference = reference,

        group = group,

        name = name,

        to_save = to_save,
        condition = condition,
    }, menu_item_mt)
end

--- @param: func: function
--- @return: void
function menu_item_c:set_callback(func)
    return menu.set_callback(self.element_type, ("%s_%s"):format(self.name, self.element_type), self.reference, func)
end

--- @vararg: any
--- @return: void
function menu_item_c:set(...)
    local args = {...}

    self.reference:set(table.unpack(args))
end

--- @param: group: string
--- @return: void
function menu_item_c:setup_group()
    self.reference:set_group(groups_en[self.group] or 1)
end

--- @vararg: string
--- @return: void
function menu_item_c:set_items(...)
    local args = {...}

    if (type(args[1]) == "table") then
        args = args[1]
    end

    self.reference:set_items(args)
end

--- @return: table
function menu_item_c:get_items()
    return self.reference:get_items()
end

--- @return: any
function menu_item_c:get()
    return self.reference:get()
end

--- @param: state: boolean
--- @return: any
function menu_item_c:set_visible(state)
    self.reference:set_visible(state)
end
--- @endregion

--- @region: menu_manager
--- @class: menu_manager_c
--- @field: public: tab: string
--- @field: public: name: string
--- @field: public: to_save: boolean
--- @field: public: condition: function
--- @field: public: reference: menu item
local menu_manager_c = {}
local menu_manager_mt = { __index = menu_manager_c }

local menu_manager_current_tab = ui.add_combobox("Current Tab:", {"Loading..."})
menu_manager_current_tab:set_group(1)

local menu_manager_tabs = {}
local menu_manager_items = {}
local current_tab = "string"

--- @info: Create a new menu_manager_c.
--- @param: tab: string
--- @param: name: string
--- @param: group: string
--- @param: to_save: boolean: optional
--- @param: condition: function: optional
--- @return: menu_manager_c
function menu_manager_c.new(tab, group, name, to_save, condition)
    return setmetatable({
        tab = tab == nil and "Global" or tab,
        name = name,
        group = group,

        to_save = to_save == nil and true or to_save,
        condition = condition == nil and function()
            return true
        end or condition,
    }, menu_manager_mt)
end

--- @param: tab: string
--- @param: name: string
--- @return: menu_item_c
function menu_manager_c.reference(tab, group, name)
    return menu_manager_items[tab][group][name].reference
end

--- @vararg: string
--- @return: menu_item_c
function menu_manager_c:combo(...)
    local args = {...}

    if (type(args[1]) == "table") then
        args = args[1]
    end

    return self:_create_item("combo", ui.add_combobox, args)
end

--- @return: menu_item_c
function menu_manager_c:checkbox()
    local item = self:_create_item("checkbox", ui.add_checkbox)

    return item
end

--- @return: menu_item_c
function menu_manager_c:hotkey()
    local item = self:_create_item("hotkey", ui.add_hotkey)

    return item
end

--- @return: menu_item_c
function menu_manager_c:label()
    self.to_save = false

    return self:_create_item("label", ui.add_label)
end

--- @param: callback: function
--- @return: menu_item_c
function menu_manager_c:button(callback)
    self.to_save = false

    local item = self:_create_item("button", ui.add_button)
    
    if (callback ~= nil) then
        callbacks.add("on_paint", function()
            if (item:get()) then
                callback()
            end
        end)
    end

    return item
end

--- @param: s_type: string
--- @param: min: number
--- @param: max: number
--- @return: menu_item_c
function menu_manager_c:slider(min, max, default_value, s_type)
    if (s_type == nil) then
        s_type = "int"
    end

    if (type(min) ~= "number") then
        cheat.notify("Slider min value must be a number.")
        return
    end

    if (type(max) ~= "number") then
        cheat.notify("Slider max value must be a number.")
        return
    end

    if (min > max) then
        cheat.notify("Slider min value must be below the max value.")
        return
    end

    local item = self:_create_item("slider", ui["add_slider"..s_type], min, max)

    if (default_value ~= nil) then
        item.reference:set(default_value)
    end

    return item
end

--- @return: menu_item_c
function menu_manager_c:color_picker()
    return self:_create_item("color_picker", ui.add_colorpicker)
end

--- @return: void
function menu_manager_c.update_visible()
    for tab_name, tab_value in pairs(menu_manager_items) do
        for item_name, item_value in pairs(tab_value) do
            local tabs = menu_manager_current_tab:get_items()
            local condition = tabs[menu_manager_current_tab:get() + 1] == tab_name and item_value.condition()

            item_value.reference:set_visible(condition)
            item_value.reference:setup_group()
        end
    end
end

--- @param: element_type: string
--- @param: element: function
--- @vararg: any
--- @return: menu_item_c
function menu_manager_c:_create_item(element_type, element, ...)
    assert(type(self.name) == "string" and self.name ~= "", 3, "Cannot create menu item: name must be a non-empty string.")

    local item = menu_item_c.new(element_type, element, self.name, self.group, self.to_save, self.condition, ...)

    if (menu_manager_items[self.tab] == nil) then
        menu_manager_items[self.tab] = {}

        table.insert(menu_manager_tabs, self.tab)
        menu_manager_current_tab:set_items(menu_manager_tabs)
    end

    if (menu_manager_items[self.tab][self.name] ~= nil) then
        return
    end

    menu_manager_items[self.tab][self.name] = {
        reference = item,
        to_save = self.to_save,
        element_type = element_type,
        condition = self.condition
    }

    local function update_value()
        menu_manager_c.update_visible()
    end

    item:set_callback(update_value)
    update_value()

    menu_manager_c.update_visible()

    return item
end

menu.set_callback("combo", "menu_manager_current_tab", menu_manager_current_tab, function()
    menu_manager_c.update_visible()
end)
--- @endregion

--- @region: input
--- @class: input_c
--- @field: public: key: number
local input_c = {}
local input_mt = { __index = input_c }

local pressed_keys = {}
local last_pressed_keys = {}

--- @info: Instantiate an object of input_c.
--- @param: key: number
--- @return input_c
function input_c.new_key(key)
    return setmetatable({
        key = key,
    }, input_mt)
end

--- @info: Update keys.
--- @return: void
function input_c.update()
    for i = 1, 255 do 
        last_pressed_keys[i] = pressed_keys[i]
        pressed_keys[i] = utils.get_active_key(i)
    end
end
callbacks.add("on_paint", input_c.update)

--- @info: Returns if current key is held
--- @return: boolean
function input_c:is_key_held()
    return pressed_keys[self.key]
end

--- @info: Returns if they key was just pressed
--- @return: boolean
function input_c:is_key_pressed()
    return pressed_keys[self.key] and not last_pressed_keys[self.key]
end

--- @info: Returns if current key was just released
--- @return: boolean
function input_c:is_key_released()
    return not pressed_keys[self.key] and last_pressed_keys[self.key]
end

--- @info: Returns if the mouse is in specified bounds.
--- @param: vec_start: vector
--- @param: vec_end: vector
--- @return: boolean
function input_c.is_mouse_in_bounds(vec_start, vec_end)
    local x, y = vec_start.x, vec_start.y
    local w, h = vec_end.x, vec_end.y

    local mouse_position = utils.get_cursor_position()

    return ((mouse_position.x >= x and mouse_position.x < x + w and mouse_position.y >= y and mouse_position.y < y + h) and globalvars.is_open_menu()) 
end
--- @endregion

--- @region: drag
--- @class: drag_c
--- @field: public: x: number
--- @field: public: y: number
--- @field: public: width: number
--- @field: public: height: number
--- @field: public: d_x: number
--- @field: public: d_y: number
--- @field: public: dragging: boolean
--- @field: public: unlocked: boolean
local drag_c = {}
local drag_mt = { __index = drag_c }

--- @info: Instantiate an object of drag_c.
--- @param: x: number
--- @param: y: number
--- @return drag_c
function drag_c.new(x, y, name, tab)
    tab = tab or "Widgets"

    local screen = engine.get_screen_size()

    return setmetatable({
        x = menu_manager_c.new(tab, "Second", ("[ %s ] x"):format(name), true, function() return false end):slider(0, screen.x, x),
        y = menu_manager_c.new(tab, "Second", ("[ %s ] y"):format(name), true, function() return false end):slider(0, screen.y, y),

        d_x = 0,
        d_y = 0,

        dragging = false,
        unlocked = false
    }, drag_mt)
end

--- @info: Unlock the dragging position.
--- @return void
function drag_c:unlock()
    self.unlocked = true
end

--- @info: Lock the dragging position.
--- @return void
function drag_c:lock()
    self.unlocked = false
end

--- @return: void
function drag_c:visualize()
    local x, y = self.x:get(), self.y:get()
    local width, height = self.width, self.height

    if (input_c.is_mouse_in_bounds(vector_2d(x, y), vector_2d(width, height))) then
        render.rect(x, y, width, height, color_c.new(255, 255, 255, 100), 3)
    end
end

--- @info: Handle dragging.
--- @param: width: number
--- @param: height: number
--- @return: void
function drag_c:handle(width, height)
    self.width = width
    self.height = height

    local screen = engine.get_screen_size()
    local mouse_position = utils.get_cursor_position()
    local mouse_left = input_c.new_key(0x01)

    if (input_c.is_mouse_in_bounds(vector_2d(self.x:get(), self.y:get()), vector_2d(self.width, self.height))) then
        if (mouse_left:is_key_held() and not self.dragging) then
            self.dragging = true

            self.d_x = self.x:get() - mouse_position.x
            self.d_y = self.y:get() - mouse_position.y
        end
    end

    if (not mouse_left:is_key_held()) then 
        self.dragging = false
    end

    if (self.dragging and globalvars.is_open_menu()) then
        local new_x = math.max(0, math.min(screen.x - self.width, mouse_position.x + self.d_x))
        local new_y = math.max(0, math.min(screen.y - self.height, mouse_position.y + self.d_y))
        new_x = self.unlocked and mouse_position.x + self.d_x or new_x
        new_y = self.unlocked and mouse_position.y + self.d_y or new_y

        self.x:set(new_x)
        self.y:set(new_y)
    end
end

--- @info: Getting drag position.
--- @return: <number, number>
function drag_c:get()
    return self.x:get(), self.y:get()
end
--- @endregion

--- @region: note
--- @class: note_c
--- @field: public: name: string
local note_c = {}
local note_mt = { __index = note_c }

--- @info: Instantiate an object of note_c.
--- @param: name: string
--- @return: note_c
function note_c.new(name)
    if (package.NecronNotes == nil) then 
        package.NecronNotes = {}
    end

    return setmetatable({
        name = name
    }, note_mt)
end

--- @param: packages: table
--- @param: sort_function: function
--- @return: any
function note_c.sort(packages, sort_function)
    local tbl = {}

    for value in pairs(packages) do 
        table.insert(tbl, value)
    end

    table.sort(tbl, sort_function)

    local index = 0
    local function update_table()
        index = index + 1

        if (tbl[index] == nil) then 
            return nil 
        else 
            return tbl[index], packages[tbl[index]]
        end 
    end

    return update_table
end

--- @param: func: function 
--- @return: number
function note_c:get(func)
    local index = 0
    local tbl = {}

    for key, value in note_c.sort(package.NecronNotes) do
        if (value == true) then
            index = index + 1

            table.insert(tbl, {key, index})
        end
    end

    for key, value in ipairs(tbl) do
        if (value[1] == self.name) then
            return func(value[2] - 1)
        end
    end
end

--- @param: value: boolean
--- @return: void
function note_c:set_state(value)
    package.NecronNotes[self.name] = value

    table.sort(package.NecronNotes)
end

--- @return: void
function note_c:unload()
    if (package.NecronNotes[self.name] ~= nil) then 
        package.NecronNotes[self.name] = nil 
    end
end
--- @endregion

--- @region: entity helpers
local entity_c = {}

--- @return: number
function entity_c.get_condition()
    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return e_conditions.SHARED
    end

    local velocity = player:get_velocity():length_2d()

    local flags = player:get_prop_int("CBasePlayer", "m_fFlags")

    if (bit.band(flags, e_player_flags.ON_GROUND) ~= 1) then
        return e_conditions.AIR
    end

    if (bit.band(flags, e_player_flags.DUCKING) ~= 0) then
        return e_conditions.CROUCH
    end

    if (velocity > 5) then
        if (ui.get_keybind_state(keybinds.slowwalk)) then
            return e_conditions.WALKING
        end

        return e_conditions.RUNNING
    end

    return e_conditions.STANDING
end

--- @param: con_id: number
--- @return: string
function entity_c.get_condition_name(con_id)
    if (con_id == nil) then
        con_id = e_conditions.SHARED
    end
    
    for key, value in spairs(e_conditions, function(t, a, b)
        return t[b] > t[a]
    end) do
        if (value == con_id) then
            local new_name = key:lower()
            new_name = new_name:gsub("(%l)(%w*)", function(a, b)
                return a:upper() .. b
            end)

            return new_name
        end
    end
end
--- @endregion

--- @region: unnamed
--- @element: script vars
local script_name = "necron"
local script_type = "stable"
local script_clan_tag = "necron"
local script_version = "1.4.0"
--- @endregion

--- @region: console helpers
local console_c = {}

--- @param: first_color: color
--- @param: second_color: color
--- @vararg: string
--- @return: void
function console_c.print_gradient(first_color, second_color, ...)
    if (first_color == nil and second_color == nil) then
        return
    end

    local args = {...}
    local message = ""

    for _, value in pairs(args) do
        message = message .. value .. "\x20"
    end

    local count = #message - 1
    local color_s = {first_color[1], first_color[2], first_color[3], first_color[4] or 255}

    local delta = {
        -(first_color[1] - second_color[1]) / count,
        -(first_color[2] - second_color[2]) / count,
        -(first_color[3] - second_color[3]) / count,
        -(first_color[4] - second_color[4]) / count
    }

    for i = 1, #message - 1 do
        console.print_color(message:sub(i, i), color_c.new(color_s[1], color_s[2], color_s[3], color_s[4]))

        color_s[1] = color_s[1] + delta[1]
        color_s[2] = color_s[2] + delta[2]
        color_s[3] = color_s[3] + delta[3]
        color_s[4] = color_s[4] + delta[4]
    end
end

--- @param: message: string
--- @param: msg_color: color
--- @return: void
function console_c.log(message, msg_color)
    if (msg_color == nil) then
        msg_color = color_c.new(255, 255, 255)
    end

    message = message .. "\n"

    local hexed = color_c.to_hex(msg_color)
    message = ("{%s}%s"):format(hexed, message)

    console_c.print_gradient({246, 166, 201, 255}, {109, 169, 240, 255}, script_name)
    console.print_color(" : ", color_c.new(33, 33, 33))

    for i = 1, message:count("{") do
        local start_prefix = message:find("{")
        local end_prefix = message:find("}")

        if (start_prefix and end_prefix) then
            local string_color = message:sub(start_prefix, end_prefix)
            local r, g, b = tonumber("0x" .. string_color:sub(2, 3)), tonumber("0x" .. string_color:sub(4, 5)), tonumber("0x" .. string_color:sub(6, 7))

            local next_string = message:sub(end_prefix + 1)

            local next_prefix_start = next_string:find('{')
            local new_string = next_prefix_start and next_string:sub(1, next_prefix_start - 1) or next_string

            message = next_string

            console.print_color(new_string, color_c.new(r, g, b))
        end
    end
end
--- @endregion

--- @region: render helpers
local render_c = {}

--- @param: x: number
--- @param: y: number
--- @param: color_s: color
--- @param: start_degrees: number
--- @param: percentage: number
--- @param: thickness: number
--- @return: void
function render_c.circle_outline(x, y, color_s, radius, start_degrees, percentage, thickness)
    local r, g, b, a = color_c.unpack(color_s)

    return render.arc(x, y, (radius - 1), (radius - 1) + thickness, start_degrees, math.floor(360 * percentage), color_c.new(r, g, b, a))
end

--- @param: font: font
--- @param: tbl: table
--- @return: vector_2d
function render_c.get_multitext_size(font, tbl)
    if (font == nil) then
        return
    end

    local width = 0

    for key, value in pairs(tbl) do
        width = width + render.get_text_size(font, tostring(value.text)).x
    end

    return {x = width, y = font.size}
end

--- @param: font: font
--- @param: x: number
--- @param: y: number
--- @param: tbl: table
--- @param: alpha: number: optional
--- @param: shadow: boolean: optional
--- @param: outline: boolean: optional
--- @return: void
function render_c.multitext(font, x, y, tbl, alpha, shadow, outline)
    if (font == nil) then
        return
    end

    if ((x == nil and type(x) ~= "number") and (y == nil and type(y) ~= "number")) then
        return
    end

    if (alpha == nil) then
        alpha = 1
    end

    if (alpha < 0) then
        alpha = 0
    end

    if (shadow == nil) then
        shadow = false
    end

    if (outline == nil) then
        outline = false
    end

    for key, value in pairs(tbl) do
        value.color = value.color or color_c.new(255, 255, 255)

        render.text(font, x, y, color_c.new(value.color:r(), value.color:g(), value.color:b(), value.color:a() * alpha), value.text, shadow, outline)

        x = x + render.get_text_size(font, value.text).x
    end
end

--- @param: x: number
--- @param: y: number
--- @param: width: number
--- @param: height: number
--- @param: container_color: color
--- @param: style: number: optional
--- @param: outline: boolean: optional
--- @return: void
function render_c.container(x, y, width, height, container_color, style, outline)
    if ((x == nil and type(x) ~= "number") and (y == nil and type(y) ~= "number")) then
        return
    end

    if ((width == nil and type(width) ~= "number") and (height == nil and type(height) ~= "number")) then
        return
    end

    if (outline == nil) then
        outline = true
    end

    if (style == nil) then
        style = 1
    end

    local r, g, b, a = color_c.unpack(container_color)

    local round = 3

    if (style == 1) then
        --- background
        render.blur(x, y, width, height, (255 / 255) * a)
        render.rect_filled(x, y, width, height, color_c.new(0, 0, 0, (80 / 255) * a))

        --- upper
        render.rect_filled(x, y, width, 2, color_c.new(r, g, b, (255 / 255) * a))
    elseif (style == 2) then
        --- background
        render.blur(x, y, width, height, (255 / 255) * a)
        render.rect_filled(x, y, width, height, color_c.new(0, 0, 0, (80 / 255) * a), round + 1)

        --- upper
        render.rect_filled(x + round, y, width - (round * 2), 1, color_c.new(r, g, b, (255 / 255) * a))

        --- left up arc
        render.begin_cliprect(x, y, round, round + 1)
        render_c.circle_outline(x + round, y + round, color_c.new(r, g, b, (255 / 255) * a), round, 180, 0.25, 1)
        render.end_cliprect()

        --- right up arc
        render.begin_cliprect(x + width - round, y, round, round + 1)
        render_c.circle_outline(x + width - round, y + round, color_c.new(r, g, b, (255 / 255) * a), round, 270, 0.25, 1)
        render.end_cliprect()

        --- left gradient
        render.gradient(x, y + round, 1, (height + 5) / 2, color_c.new(r, g, b, (255 / 255) * a), color_c.new(r, g, b, (0 / 255) * a), 1)

        --- right gradient
        render.gradient(x + width - 1, y + round, 1, (height + 5) / 2, color_c.new(r, g, b, (255 / 255) * a), color_c.new(r, g, b, (0 / 255) * a), 1)
    end
end
--- @endregion

--- @region: fonts
local fonts = {}

fonts.small = {}
fonts.verdana = {}

fonts.verdana.default = render.setup_font("Verdana", 12, fontflags.noantialiasing)
fonts.verdana.bold = render.setup_font("Verdana", 13, fontflags.bold)

fonts.small.default = font_c.new({
    link = "https://cdn.discordapp.com/attachments/935910251562143764/1027915433929609256/smallest.ttf",
    type = "ttf",
    name = "smallest"
}, 10):init()
--- @endregion

--- @region: ui
--- @group: Global
local ui_global = {}

ui_global.export_button = menu_manager_c.new("Global", "Second", "Export Config To Clipboard"):button()
ui_global.import_button = menu_manager_c.new("Global", "Second", "Import Config From Clipboard"):button()
ui_global.default_button = menu_manager_c.new("Global", "Second", "Load Default Config"):button()

ui_global.seperator = menu_manager_c.new("Global", "Second", " "):label()

ui_global.discord_link = menu_manager_c.new("Global", "Second", "Export Discord Link To Console"):button(function()
    local link = ("tPfYp4WeXq"):gradient({246, 166, 201, 255}, {109, 169, 240, 255})
    console_c.log("https://discord.gg/" .. link)
end)

--- @group: Anti-Aim
local ui_anti_aim = {}

ui_anti_aim.switch = menu_manager_c.new("Anti-Aim", "Second", "Enable Anti-Aims"):checkbox()
ui_anti_aim.switch_condition = function() return ui_anti_aim.switch:get() end

ui_anti_aim.static_legs_in_air = menu_manager_c.new("Anti-Aim", "Second", "Static Legs In Air", true, ui_anti_aim.switch_condition):checkbox()
ui_anti_aim.zero_pitch_on_land = menu_manager_c.new("Anti-Aim", "Second", "Zero Pitch On Land", true, ui_anti_aim.switch_condition):checkbox()
ui_anti_aim.static_legs_on_slow_walk = menu_manager_c.new("Anti-Aim", "Second", "Static Legs On Slow Walk", true, ui_anti_aim.switch_condition):checkbox()

ui_anti_aim.mode = menu_manager_c.new("Anti-Aim", "Second", "Anti-Aim Mode", true, ui_anti_aim.switch_condition):combo("None", "Condition")

--- @group: Widgets
local ui_widgets = {}

ui_widgets.switch = menu_manager_c.new("Widgets", "Second", "Enable Widgets"):checkbox()
ui_widgets.switch_condition = function() return ui_widgets.switch:get() end

ui_widgets.main_color = menu_manager_c.new("Widgets", "First", "Main Color", true, ui_widgets.switch_condition):color_picker()
ui_widgets.first_color = menu_manager_c.new("Widgets", "First", "First Color", true, ui_widgets.switch_condition):color_picker()
ui_widgets.second_color = menu_manager_c.new("Widgets", "First", "Second Color", true, ui_widgets.switch_condition):color_picker()

ui_widgets.glow_switch = menu_manager_c.new("Widgets", "First", "Enable Glow", true, ui_widgets.switch_condition):checkbox()
ui_widgets.glow_switch_condition = function() return ui_widgets.switch_condition() and ui_widgets.glow_switch:get() end
ui_widgets.glow_color = menu_manager_c.new("Widgets", "First", "Glow Color", true, ui_widgets.glow_switch_condition):color_picker()

ui_widgets.sty_seperator = menu_manager_c.new("Widgets", "First", "    "):label()
ui_widgets.style = menu_manager_c.new("Widgets", "First", "Windows style", true, ui_widgets.switch_condition):combo("Default", "Alternative")

ui_widgets.watermark = menu_manager_c.new("Widgets", "Second", "Enable Watermark", true, ui_widgets.switch_condition):checkbox()
ui_widgets.keybinds = menu_manager_c.new("Widgets", "Second", "Enable Keybinds", true, ui_widgets.switch_condition):checkbox()
ui_widgets.indicators = menu_manager_c.new("Widgets", "Second", "Enable Crosshair Indicators", true, ui_widgets.switch_condition):checkbox()

ui_widgets.hit_log = menu_manager_c.new("Widgets", "Second", "Enable On Screen Shot Log", true, ui_widgets.switch_condition):checkbox()
ui_widgets.hit_log_condition = function() return ui_widgets.switch_condition() and ui_widgets.hit_log:get() end
ui_widgets.manage_color = menu_manager_c.new("Widgets", "Second", "Manage Colors", true, ui_widgets.hit_log_condition):checkbox()
ui_widgets.manage_color_condition = function() return ui_widgets.hit_log_condition() and ui_widgets.manage_color:get() end
ui_widgets.hit_seperator = menu_manager_c.new("Widgets", "First", "   "):label()
ui_widgets.hit_color = menu_manager_c.new("Widgets", "First", "Hit Color", true, ui_widgets.manage_color_condition):color_picker()
ui_widgets.miss_color = menu_manager_c.new("Widgets", "First", "Miss Color", true, ui_widgets.manage_color_condition):color_picker()

ui_widgets.seperator = menu_manager_c.new("Widgets", "Second", "  ", ui_widgets.manage_color_condition):label()

ui_widgets.clan_tag = menu_manager_c.new("Widgets", "Second", "Enable Clantag Spammer", true, ui_widgets.switch_condition):checkbox()
menu.set_callback("checkbox", ("%s_%s"):format("Enable Clantag Spammer - Widgets", "checkbox"), ui_widgets.clan_tag.reference, function(new_value)
    engine.set_clantag(script_clan_tag)

    if (not new_value) then
        engine.set_clantag("")
    end
end)
--- @endregion

--- @region: anti-aim
--- @item: Condition Anti-Aim Mode
local condition_anti_aim = {}

condition_anti_aim.list = {}

condition_anti_aim.switch = false
condition_anti_aim.yaw = 0

condition_anti_aim.fake_switch = false
condition_anti_aim.fake = 0

condition_anti_aim.mode_condition = function() return ui_anti_aim.mode:get() == 1 end
condition_anti_aim.conditions = menu_manager_c.new("Anti-Aim", "Second", "Current Condition", true, condition_anti_aim.mode_condition):combo("none")

function condition_anti_aim.update_items()
    local conditions = {}

    for key, value in spairs(e_conditions, function(t, a, b)
        return t[b] > t[a]
    end) do
        local new_name = key:lower()
        new_name = new_name:gsub("(%l)(%w*)", function(a, b)
            return a:upper() .. b
        end)

        table.insert(conditions, new_name)
    end

    condition_anti_aim.conditions:set_items(conditions)
end; condition_anti_aim.update_items()

function condition_anti_aim.create_items()
    local items = condition_anti_aim.conditions.reference:get_items()

    for key, value in ipairs(items) do
        local function name(text)
            return ("[%s] %s"):format(value, text)
        end

        if (condition_anti_aim.list[key] == nil) then
            condition_anti_aim.list[key] = {}
        end

        local setup = condition_anti_aim.list[key]

        setup.override = menu_manager_c.new("Anti-Aim", "Second", name("Override"), true, function()
            return condition_anti_aim.conditions:get() == key-1 and condition_anti_aim.mode_condition()
        end):checkbox()

        local function visible_condition()
            return condition_anti_aim.conditions:get() == key-1 and condition_anti_aim.mode_condition() and setup.override:get()
        end

        setup.pitch = menu_manager_c.new("Anti-Aim", "Second", name("Pitch"), true, visible_condition):combo("None", "Minimal", "Maximal")
        
        setup.target_yaw = menu_manager_c.new("Anti-Aim", "Second", name("Target Yaw"), true, visible_condition):combo("Local View", "At Targets")

        setup.yaw_offset_type = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Add Type"), true, visible_condition):combo("Default", "Alternative")
        setup.yaw_offset = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Offset"), true, function() return visible_condition() and setup.yaw_offset_type:get() == 0 end):slider(-180, 180, 0)

        setup.yaw_offset_left = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Offset Left"), true, function() return visible_condition() and setup.yaw_offset_type:get() == 1 end):slider(-180, 180, 0)
        setup.yaw_offset_right = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Offset Right"), true, function() return visible_condition() and setup.yaw_offset_type:get() == 1 end):slider(-180, 180, 0)

        setup.yaw_jitter = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Jitter"), true, visible_condition):combo("Off", "Offset", "Center", "Random")
        setup.yaw_jitter_value = menu_manager_c.new("Anti-Aim", "Second", name("Yaw Jitter Value"), true, function() return visible_condition() and setup.yaw_jitter:get() ~= 0 end):slider(-180, 180, 0)

        setup.spin_switch = menu_manager_c.new("Anti-Aim", "Second", name("Spin Anti-Aim"), true, function() return visible_condition() and setup.yaw_jitter:get() == 0 end):checkbox()

        setup.spin_range = menu_manager_c.new("Anti-Aim", "Second", name("Spin Range"), true, function() return visible_condition() and setup.spin_switch:get() and setup.yaw_jitter:get() == 0 end):slider(1, 180)
        setup.spin_speed = menu_manager_c.new("Anti-Aim", "Second", name("Spin Speed"), true, function() return visible_condition() and setup.spin_switch:get() and setup.yaw_jitter:get() == 0 end):slider(1, 15)

        setup.desync_type = menu_manager_c.new("Anti-Aim", "Second", name("Desync Type"), true, visible_condition):combo("None", "Static", "Jitter")

        setup.desync_range = menu_manager_c.new("Anti-Aim", "Second", name("Desync Range"), true, function() return visible_condition() and setup.desync_type:get() ~= 0 end):slider(1, 60)
        setup.inv_desync_range = menu_manager_c.new("Anti-Aim", "Second", name("Inverted Desync Range"), true, function() return visible_condition() and setup.desync_type:get() ~= 0 end):slider(1, 60)

        setup.body_lean = menu_manager_c.new("Anti-Aim", "Second", name("Body Lean"), true, function() return visible_condition() and setup.desync_type:get() ~= 0 end):slider(1, 60)
        setup.inv_body_lean = menu_manager_c.new("Anti-Aim", "Second", name("Inverted Body Lean"), true, function() return visible_condition() and setup.desync_type:get() ~= 0 end):slider(1, 60)
    end
end; condition_anti_aim.create_items()

function condition_anti_aim.handle()
    if (not ui_anti_aim.switch:get() or ui_anti_aim.mode:get() ~= 1) then
        return
    end

    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return
    end

    local current_condition = entity_c.get_condition()
    local item = condition_anti_aim.list[current_condition]
    item = condition_anti_aim.list[e_conditions.SHARED].override:get() and condition_anti_aim.list[e_conditions.SHARED] or item

    if (not item.override:get()) then
        return
    end

    local is_left = ui.get_keybind_state(keybinds.flip_desync)

    local yaw_offset = 0
    if (item.yaw_offset_type:get() == 0) then
        yaw_offset = item.yaw_offset:get()
    elseif (item.yaw_offset_type:get() == 1) then
        yaw_offset = is_left and item.yaw_offset_left:get() or item.yaw_offset_right:get()
    end

    if (item.yaw_jitter:get() == 0) then
        e_menu.YAW:set(yaw_offset)
    end

    e_menu.PITCH:set(item.pitch:get())

    e_menu.TARGET_YAW:set(item.target_yaw:get())

    if (utils.get_choked_commands() == 0) then
        if (item.yaw_jitter:get() ~= 0) then
            e_menu.YAW_MOD:set(0)

            if (item.yaw_jitter:get() == 1) then
                if (condition_anti_aim.switch) then
                    condition_anti_aim.yaw = yaw_offset
                else
                    condition_anti_aim.yaw = yaw_offset + item.yaw_jitter_value:get()
                end

                condition_anti_aim.switch = not condition_anti_aim.switch
            elseif (item.yaw_jitter:get() == 2) then
                if (condition_anti_aim.switch) then
                    condition_anti_aim.yaw = yaw_offset - item.yaw_jitter_value:get() / 2
                else
                    condition_anti_aim.yaw = yaw_offset + item.yaw_jitter_value:get() / 2
                end

                condition_anti_aim.switch = not condition_anti_aim.switch
            elseif (item.yaw_jitter:get() == 3) then
                condition_anti_aim.yaw = yaw_offset + math.random_int(item.yaw_jitter_value:get() / -2, item.yaw_jitter_value:get() / 2)
            end

            e_menu.YAW:set(math.floor(condition_anti_aim.yaw or 0))
        end
    end

    if (item.spin_switch:get() and item.yaw_jitter:get() == 0) then
        e_menu.YAW_MOD:set(2)

        e_menu.SPIN_RANGE:set(item.spin_range:get())
        e_menu.SPIN_SPEED:set(item.spin_speed:get())
    end

    if (not item.spin_switch:get()) then
        e_menu.YAW_MOD:set(0)
    end

    e_menu.DESYNC_TYPE:set(item.desync_type:get())

    if (item.desync_type:get() ~= 0) then
        e_menu.DESYNC_RANGE:set(item.desync_range:get())
        e_menu.INV_DESYNC_RANGE:set(item.inv_desync_range:get())

        e_menu.BODY_LEAN:set(item.body_lean:get())
        e_menu.INV_BODY_LEAN:set(item.inv_body_lean:get())
    end
end

--- @item: Animation Breakers
local anim_breaker = {}

anim_breaker.ground_ticks = 1
anim_breaker.end_time = 0

function anim_breaker.handle(stage)
    if (not ui_anti_aim.switch:get()) then
        return
    end

    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return
    end

    if (stage ~= enum_frames.frame_render_start) then
        return
    end

    local flags = player:get_prop_int("CBasePlayer", "m_fFlags")
    local on_ground = bit.band(flags, e_player_flags.ON_GROUND) == 1

    if (ui_anti_aim.static_legs_in_air:get()) then
        if (not on_ground) then
            player:set_render_pose(e_poses.JUMP_FALL, 1)
        end
    end

    if (ui_anti_aim.zero_pitch_on_land:get()) then
        if (on_ground) then
            anim_breaker.ground_ticks = anim_breaker.ground_ticks + 1
        else
            anim_breaker.ground_ticks = 0
            anim_breaker.end_time = globalvars.get_curtime() + 1
        end

        if (anim_breaker.ground_ticks > (e_menu.FAKELAG_AMOUNT:get() + 1) and anim_breaker.end_time > globalvars.get_curtime()) then
            player:set_render_pose(e_poses.BODY_PITCH, 0.5)
        end
    end

    if (ui_anti_aim.static_legs_on_slow_walk:get()) then
        if (ui.get_keybind_state(keybinds.slowwalk)) then
            player:set_render_pose(e_poses.MOVE_BLEND_WALK, 0)
        end
    end
end
--- @endregion

--- @region: widgets
--- @item: Watermark
local watermark_c = {}

watermark_c.note = note_c.new("a_watermark")

function watermark_c.handle()
    watermark_c.note:set_state(ui_widgets.watermark:get() and ui_widgets.switch:get())
    watermark_c.note:get(function(id)
        local f_r, f_g, f_b = color_c.unpack(ui_widgets.first_color:get())
        local s_r, s_g, s_b = color_c.unpack(ui_widgets.second_color:get())
        local a_r, a_g, a_b = color_c.unpack(ui_widgets.main_color:get())
        local g_r, g_g, g_b = color_c.unpack(ui_widgets.glow_color:get())

        local actual_time = globalvars.get_time()
        local nickname = engine.get_gamename()

        local text = {
            {text = (" [%s]"):format(script_type)},
            {text = ("  %s"):format(nickname)},
        }

        if (engine.is_in_game()) then
            local latency = globalvars.get_ping()

            local latency_text = ("  %dms"):format(latency)

            table.insert(text, {text = latency_text})
        end

        table.insert(text, {text = ("  %s"):format(actual_time:sub(0, 5))})

        local script_size = render.get_text_size(fonts.verdana.default, script_name)
        local text_size = render_c.get_multitext_size(fonts.verdana.default, text)

        local x, y = engine.get_screen_size().x, 8 + (27*0)
        local space = 6

        local y_add = {
            [0] = 1,
            [1] = 0
        }

        local width, height = (script_size.x + text_size.x) + (10 + space), 23

        x = x - width - 10

        if (ui_widgets.glow_switch:get()) then
            render.rect_shadow_ex(vector_2d(x + 1, y + 1), vector_2d(width - 2, height - 2), 16, vector(1, 22, 2), 4, color_c.new(g_r, g_g, g_b), 0, -1)
        end

        render_c.container(x, y, width, height, color_c.new(a_r, a_g, a_b), ui_widgets.style:get() + 1)

        render.text_gradient(fonts.verdana.default, x + space + 1, y + (height / 2) - (script_size.y / 2) + y_add[ui_widgets.style:get()], color_c.new(f_r, f_g, f_b), color_c.new(s_r, s_g, s_b), script_name, 0, true)

        render_c.multitext(fonts.verdana.default, x + script_size.x + space + 2, y + (height / 2) - (text_size.y / 2) + y_add[ui_widgets.style:get()], text, 1, true)
    end)
end

--- @item: Indicators
local indicators_c = {}

function indicators_c.handle()
    if (not ui_widgets.indicators:get() or not ui_widgets.switch:get()) then
        return
    end

    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return
    end

    local f_r, f_g, f_b = color_c.unpack(ui_widgets.first_color:get())
    local s_r, s_g, s_b = color_c.unpack(ui_widgets.second_color:get())
    local a_r, a_g, a_b = color_c.unpack(ui_widgets.main_color:get())
    local g_r, g_g, g_b = color_c.unpack(ui_widgets.glow_color:get())

    local screen = engine.get_screen_size()

    local text_size = render.get_text_size(fonts.small.default, script_name:upper())

    local additional = 40
    local x, y = screen.x / 2, (screen.y / 2) + additional

    if (ui_widgets.glow_switch:get()) then
        render.rect_shadow_ex(vector_2d(x - (text_size.x / 2), y - ((text_size.y - 5) / 2)), vector_2d(text_size.x, (text_size.y - 5)), 22, vector(1, 25, 2), 8, color_c.new(g_r, g_g, g_b), 0, 0)
    end

    render.text_gradient(fonts.small.default, x - (text_size.x / 2), y - (text_size.y / 2), color_c.new(f_r, f_g, f_b), color_c.new(s_r, s_g, s_b), script_name:upper(), 0, false, true)

    local list = {
        {
            name = {
                {text = "- ", color = color_c.new(255, 255, 255)},
                {text = entity_c.get_condition_name(entity_c.get_condition()), color = color_c.new(a_r, a_g, a_b)},
                {text = " -", color = color_c.new(255, 255, 255)}
            },

            active = true
        },
        {
            name = "DT",
            active = ui.get_keybind_state(keybinds.double_tap)
        },
        {
            name = "HS",
            active = ui.get_keybind_state(keybinds.hide_shots)
        },
        {
            name = "DMG",
            active = ui.get_keybind_state(keybinds.damage_override)
        },
        {
            name = "BODY", 
            active = ui.get_keybind_state(keybinds.body_aim)
        },
    }

    local offset = 0

    for key, value in ipairs(list) do
        local alpha = animation.create(("[%s] list / indicators"):format(key), value.active and 1 or 0, 12)

        if (alpha < 0) then
            alpha = 0
        end

        if (type(value.name) == "table") then
            local list_size = render_c.get_multitext_size(fonts.small.default, value.name)
            local new_x = animation.create(("[%s] list / new_x table"):format(key), x - (list_size.x / 2), 12)

            render_c.multitext(fonts.small.default, math.floor(new_x), y - (list_size.y / 2) + (text_size.y - 2) + offset, value.name, alpha, false, true)
        elseif (type(value.name) == "string") then
            local list_size = render.get_text_size(fonts.small.default, value.name)
            local new_x = animation.create(("[%s] list / new_x string"):format(key), x - (list_size.x / 2), 12)

            render.text(fonts.small.default, math.floor(new_x), y - (list_size.y / 2) + (text_size.y - 2) + offset, color_c.new(a_r, a_g, a_b, 255 * alpha), value.name, false, true)
        end

        offset = offset + 8 * alpha
    end
end

--- @item: Keybinds
local keybinds_c = {}

keybinds_c.active = {}

keybinds_c.list = {
    ["Minimum damage"] = keybinds.damage_override,
    ["Double tap"] = keybinds.double_tap,
    ["On shot anti-aim"] = keybinds.hide_shots,
    ["Slow motion"] = keybinds.slowwalk,
    ["Anti-aim inverter"] = keybinds.flip_desync,
    ["Duck peek assist"] = keybinds.fakeduck,
    ["Quick peek assist"] = keybinds.automatic_peek,
    ["Body aim"] = keybinds.body_aim
}

keybinds_c.modes = {"always", "holding", "toggled", "disabled"}

keybinds_c.dragging = drag_c.new(0, 0, "Keybinds")

function keybinds_c.handle()
    if (not ui_widgets.keybinds:get() or not ui_widgets.switch:get()) then
        return
    end

    local a_r, a_g, a_b = color_c.unpack(ui_widgets.main_color:get())
    local g_r, g_g, g_b = color_c.unpack(ui_widgets.glow_color:get())

    local latest_item = false
    local maximum_offset = 66

    local menu_bind = true

    for bind_name, bind_ref in pairs(keybinds_c.list) do
        local item_active = ui.get_keybind_state(bind_ref)

        if (item_active) then
            latest_item = true

            if (keybinds_c.active[bind_name] == nil) then
                keybinds_c.active[bind_name] = {mode = "", alpha = 0, offset = 0, active = false}
            end

            local bind_name_size = render.get_text_size(fonts.verdana.default, bind_name)

            keybinds_c.active[bind_name].mode = keybinds_c.modes[ (ui.get_keybind_mode(bind_ref) + 2) or 4 ]

            keybinds_c.active[bind_name].alpha = animation.lerp(keybinds_c.active[bind_name].alpha, 1, 12)
            keybinds_c.active[bind_name].offset = bind_name_size.x

            keybinds_c.active[bind_name].active = true
        elseif (keybinds_c.active[bind_name] ~= nil) then
            keybinds_c.active[bind_name].alpha = animation.lerp(keybinds_c.active[bind_name].alpha, 0, 12)
            keybinds_c.active[bind_name].active = false

            if (keybinds_c.active[bind_name].alpha < 0.01) then
                keybinds_c.active[bind_name] = nil
            end
        end

        if (keybinds_c.active[bind_name] ~= nil and keybinds_c.active[bind_name].offset > maximum_offset) then
            maximum_offset = keybinds_c.active[bind_name].offset
        end
    end

    local alpha = animation.create("keybinds [alpha]", (globalvars.is_open_menu() or table.count(keybinds_c.active) > 0 and latest_item) and 1 or 0, 12)

    if (alpha < 0) then
        alpha = 0
    end

    local text = "keybinds"
    local text_size = render.get_text_size(fonts.verdana.default, text)

    local x, y = keybinds_c.dragging:get()

    local width, height = math.floor(animation.create("keybinds [width]", 75 + maximum_offset, 8)), 23
    local height_offset = height + 5

    if (alpha > 0.1 and ui_widgets.glow_switch:get()) then
        render.rect_shadow_ex(vector_2d(x + 1, y + 1), vector_2d(width - 2, height - 2), 16, vector(1, 22, 2), 4*alpha, color_c.new(g_r, g_g, g_b), 0, -1)
    end

    render_c.container(x, y, width, height, color_c.new(a_r, a_g, a_b, 255*alpha), ui_widgets.style:get() + 1)

    render.text(fonts.verdana.default, x + (width / 2) - (text_size.x / 2), y + (height / 2) - (text_size.y / 2) + 1, color_c.new(255, 255, 255, 255*alpha), text, true)

    for bind_name, value in pairs(keybinds_c.active) do
        local key_type = "[" .. (value.mode or "?") .. "]"
        local key_type_size = render.get_text_size(fonts.verdana.default, key_type)

        if (value.alpha < 0) then
            value.alpha = 0
        end

        render.text(fonts.verdana.default, x + 5, y + height_offset, color_c.new(255, 255, 255, 255*alpha*value.alpha), bind_name, true)
        render.text(fonts.verdana.default, x + width - key_type_size.x - 5, y + height_offset, color_c.new(255, 255, 255, 255*alpha*value.alpha), key_type, true)

        height_offset = height_offset + 15 * value.alpha
    end

    keybinds_c.dragging:handle(width, (table.count(keybinds_c.active) > 0 and height_offset or height))
end

--- @item: Hit Log
local hit_log_c = {}

hit_log_c.groups = {"head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "gear"}
hit_log_c.miss_types = {
    ["none"] = "?",
    ["resolver"] = "bad resolve",
    ["spread"] = "spread",
    ["occlusion"] = "occlusion",
    ["prediction error"] = "pred. error",
    ["unregistered"] = "unregistered"
}

hit_log_c.list = {}

hit_log_c.remaining = 0

function hit_log_c.hit_event(event)
    if (event:get_name() ~= "player_hurt") then
        return
    end

    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return
    end

    local userid = entity.get_player_by_index(engine.get_player_for_user_id(event:get_int("userid")))
    local attacker = entity.get_player_by_index(engine.get_player_for_user_id(event:get_int("attacker")))

    local remaining = event:get_int("health")

    if (attacker:get_index() ~= player:get_index()) then
        return
    end

    hit_log_c.remaining = remaining
end

function hit_log_c.shot_event(event)
    if (event.result ~= "Hit") then
        local color_miss = ui_widgets.manage_color:get() and ui_widgets.miss_color:get() or color_c.new(255, 150, 150)

        local text = {
            {text = "Missed "},
            {text = event.target_name, color = color_miss},
            {text = "`s "},
            {text = event.client_hitbox:lower() or "?", color = color_miss},
            {text = " due to "},
            {text = hit_log_c.miss_types[event.result:lower()] or "?", color = color_miss},
            {text = " ("},
            {text = tostring(event.hitchance), color = color_miss},
            {text = " HC)"}
        }

        table.insert(hit_log_c.list, 1, {text = text, time = 6, alpha = 0, animate = -90, color = color_miss})

        return
    end

    local color_hit = ui_widgets.manage_color:get() and ui_widgets.hit_color:get() or color_c.new(47, 255, 72)

    local text = {
        {text = "Hit "},
        {text = event.target_name, color = color_hit},
        {text = " in the "},
        {text = event.server_hitbox:lower() or "?", color = color_hit},
        {text = " for "},
        {text = tostring(event.server_damage), color = color_hit},
        {text = " damage ("},
        {text = tostring(hit_log_c.remaining), color = color_hit},
        {text = " health remaining)"}
    }

    table.insert(hit_log_c.list, 1, {text = text, time = 6, alpha = 0, animate = -90, color = color_hit})
end

function hit_log_c.handle()
    if (not ui_widgets.hit_log:get() or not ui_widgets.switch:get()) then
        return
    end

    local player = entity.get_local()

    if (player == nil or not player:is_alive()) then
        return
    end

    local g_r, g_g, g_b = color_c.unpack(ui_widgets.glow_color:get())

    local screen = engine.get_screen_size()

    local additional = 200
    local x, y = screen.x / 2, (screen.y / 2) + additional

    local offset = 0
    for key, value in ipairs(hit_log_c.list) do
        value.time = value.time - globalvars.get_frametime()

        value.alpha = animation.lerp(value.alpha, value.time <= 0 and 0 or 1, 12)
        value.animate = animation.lerp(value.animate, value.time <= 0.1 and 90 or 0, 12)

        local text_size = render_c.get_multitext_size(fonts.verdana.default, value.text)

        local t_r, t_g, t_b = color_c.unpack(value.color)

        if (value.alpha > 0.1 and ui_widgets.glow_switch:get()) then
            render.rect_filled(x - (text_size.x / 2) + value.animate, y + offset + 6, text_size.x, 1, color_c.new(t_r, t_g, t_b, 20*value.alpha))
            render.rect_shadow_ex(vector_2d(x - (text_size.x / 2) + value.animate, y + offset + 6), vector_2d(text_size.x, 1), 22, vector(1, 25, 2), 6*value.alpha, value.color, 0, 0)
        end

        render_c.multitext(fonts.verdana.default, x - (text_size.x / 2) + value.animate, y + offset, value.text, value.alpha, true)

        if (#hit_log_c.list > 6 or value.alpha < 0.01) then
            table.remove(hit_log_c.list, key)
        end

        offset = offset + 13 * value.alpha
    end
end
--- @endregion

--- @region: config
local config_c = {}

--- @return: void
function config_c.export()
    local status, message = pcall(function()
        local items = {}

        for tab_name, tab_value in pairs(menu_manager_items) do
            items[tab_name] = {}

            for item_name, item_value in pairs(tab_value) do
                local temp = {}

                if (not item_value.to_save) then
                    goto skip
                end

                temp.value = item_value.reference:get()

                if (type(temp.value) == "userdata") then
                    temp.value = {temp.value:r(), temp.value:g(), temp.value:b(), temp.value:a()}
                end

                if (temp.value == nil) then
                    goto skip
                end

                items[tab_name][item_name] = temp
                ::skip::
            end
        end

        local config = json.encode(items)

        utils.set_clipboard(config)

        local text_gradient = ("clipboard"):gradient({246, 166, 201, 255}, {109, 169, 240, 255})
        console_c.log("Config exported to " .. text_gradient .. "{ffffff}.")
    end)

    if (not status) then
        local message_gradient = message:gradient({246, 166, 201, 255}, {109, 169, 240, 255})
        console_c.log("Failed to export config: " .. message_gradient)

        return
    end
end

--- @param: text: string
--- @return: void
function config_c.import(text)
    local status, message = pcall(function()
        local config = json.decode(text)

        if (config == nil) then
            error("Wrong config")
            return
        end

        for tab_name, tab_value in pairs(config) do
            for item_name, config_value in pairs(tab_value) do
                local item = menu_manager_items[tab_name][item_name]

                if (item == nil or config_value.value == nil) then
                    goto skip
                end

                if (type(config_value.value) == "table") then
                    item.reference:set(color_c.new(table.unpack(config_value.value)))
                else
                    item.reference:set(config_value.value)
                end
                ::skip::
            end
        end

        local text_gradient = ("config"):gradient({246, 166, 201, 255}, {109, 169, 240, 255})
        console_c.log("Applied imported " .. text_gradient .. "{ffffff}.")
    end)

    if (not status) then
        local message_gradient = message:gradient({246, 166, 201, 255}, {109, 169, 240, 255})
        console_c.log("Failed to import config: " .. message_gradient)

        return
    end
end

ui_global.export_button:set_callback(config_c.export)
ui_global.import_button:set_callback(function()
    local data = utils.get_clipboard()
    
    config_c.import(data)
end)
ui_global.default_button:set_callback(function()
    local data = [[{"Anti-Aim":{"[Air] Inverted Body Lean":{"value":1},"Enable Anti-Aims":{"value":true},"[Crouch] Inverted Body Lean":{"value":1},"[Shared] Inverted Desync Range":{"value":1},"[Shared] Body Lean":{"value":1},"[Running] Yaw Offset Right":{"value":0},"[Crouch] Yaw Offset Left":{"value":0},"[Standing] Inverted Desync Range":{"value":56},"[Shared] Inverted Body Lean":{"value":1},"[Standing] Spin Anti-Aim":{"value":false},"[Air] Override":{"value":true},"[Running] Target Yaw":{"value":1},"[Walking] Desync Range":{"value":60},"[Walking] Yaw Offset Right":{"value":-1},"[Running] Desync Range":{"value":56},"[Crouch] Spin Anti-Aim":{"value":false},"[Standing] Yaw Offset Left":{"value":-4},"[Air] Target Yaw":{"value":1},"[Crouch] Yaw Jitter Value":{"value":-18},"[Shared] Yaw Jitter":{"value":0},"[Air] Yaw Offset":{"value":-4},"[Running] Inverted Desync Range":{"value":56},"[Air] Spin Anti-Aim":{"value":false},"[Standing] Pitch":{"value":1},"[Standing] Spin Speed":{"value":1},"[Crouch] Yaw Add Type":{"value":0},"[Air] Yaw Add Type":{"value":0},"Current Condition":{"value":5},"[Running] Pitch":{"value":1},"[Shared] Yaw Offset":{"value":0},"[Shared] Yaw Offset Left":{"value":0},"[Standing] Desync Type":{"value":2},"[Air] Yaw Jitter Value":{"value":-29},"[Air] Desync Type":{"value":2},"[Crouch] Spin Speed":{"value":1},"[Shared] Spin Range":{"value":1},"[Air] Spin Range":{"value":1},"[Crouch] Yaw Jitter":{"value":2},"[Shared] Desync Type":{"value":0},"[Shared] Yaw Add Type":{"value":0},"[Crouch] Desync Type":{"value":2},"[Shared] Target Yaw":{"value":0},"Zero Pitch On Land":{"value":false},"[Shared] Yaw Offset Right":{"value":0},"[Standing] Body Lean":{"value":1},"[Air] Desync Range":{"value":60},"[Shared] Pitch":{"value":0},"[Running] Body Lean":{"value":1},"[Standing] Spin Range":{"value":1},"[Standing] Override":{"value":true},"Static Legs On Slow Walk":{"value":false},"[Air] Yaw Offset Left":{"value":0},"[Walking] Target Yaw":{"value":1},"[Air] Spin Speed":{"value":1},"[Running] Spin Speed":{"value":1},"[Walking] Spin Range":{"value":1},"[Air] Pitch":{"value":1},"[Crouch] Yaw Offset":{"value":4},"[Running] Desync Type":{"value":2},"[Shared] Override":{"value":false},"[Running] Spin Range":{"value":1},"[Walking] Pitch":{"value":1},"[Running] Inverted Body Lean":{"value":1},"[Standing] Target Yaw":{"value":1},"[Crouch] Override":{"value":true},"[Air] Inverted Desync Range":{"value":60},"[Walking] Spin Speed":{"value":1},"[Running] Spin Anti-Aim":{"value":false},"[Walking] Inverted Desync Range":{"value":60},"[Walking] Override":{"value":true},"[Running] Override":{"value":true},"[Walking] Yaw Jitter Value":{"value":0},"Anti-Aim Mode":{"value":1},"[Walking] Yaw Offset Left":{"value":0},"[Shared] Yaw Jitter Value":{"value":0},"[Running] Yaw Offset Left":{"value":4},"[Crouch] Target Yaw":{"value":1},"[Walking] Body Lean":{"value":1},"[Air] Yaw Jitter":{"value":2},"[Crouch] Body Lean":{"value":1},"Static Legs In Air":{"value":true},"[Crouch] Desync Range":{"value":60},"[Shared] Spin Anti-Aim":{"value":false},"[Standing] Yaw Offset Right":{"value":4},"[Walking] Desync Type":{"value":2},"[Walking] Spin Anti-Aim":{"value":false},"[Crouch] Inverted Desync Range":{"value":60},"[Standing] Desync Range":{"value":56},"[Walking] Yaw Jitter":{"value":0},"[Standing] Yaw Add Type":{"value":1},"[Walking] Inverted Body Lean":{"value":1},"[Shared] Spin Speed":{"value":1},"[Standing] Yaw Jitter Value":{"value":-19},"[Running] Yaw Add Type":{"value":1},"[Crouch] Spin Range":{"value":1},"[Shared] Desync Range":{"value":1},"[Walking] Yaw Offset":{"value":0},"[Air] Body Lean":{"value":1},"[Running] Yaw Offset":{"value":0},"[Air] Yaw Offset Right":{"value":0},"[Standing] Inverted Body Lean":{"value":1},"[Running] Yaw Jitter Value":{"value":-12},"[Standing] Yaw Offset":{"value":0},"[Standing] Yaw Jitter":{"value":2},"[Crouch] Pitch":{"value":1},"[Running] Yaw Jitter":{"value":2},"[Walking] Yaw Add Type":{"value":1},"[Crouch] Yaw Offset Right":{"value":0}},"Widgets":{"Miss Color":{"value":[255,255,255,255]},"Enable Widgets":{"value":true},"[ Keybinds ] x":{"value":998},"Enable Keybinds":{"value":true},"Hit Color":{"value":[255,255,255,255]},"Accent":{"value":[253,152,111,255]},"Enable Clantag Spammer":{"value":false},"Left Gradient Color":{"value":[255,255,255,255]},"[ Keybinds ] y":{"value":131},"Indicators":{"value":1},"Enable Watermark":{"value":false},"Manage Colors":{"value":false},"Windows Style":{"value":1},"Enable Hit Log":{"value":true},"Right Gradient Color":{"value":[255,255,255,255]},"Indicators Color":{"value":[253,152,111,255]}},"Global":[]}]]
    
    config_c.import(data)
end)
--- @endregion

--- @region: setup
--- @return: void
local function on_load()
    console.execute_client_cmd("clear")
    console.execute_client_cmd("showconsole")

    local user_name = engine.get_gamename():gradient({246, 166, 201, 255}, {109, 169, 240, 255})
    local author = ("Klient#1690"):gradient({246, 166, 201, 255}, {109, 169, 240, 255})
    local type = (script_type:gsub("^%l", string.upper)):gradient({246, 166, 201, 255}, {109, 169, 240, 255})
    local version = script_version:gradient({246, 166, 201, 255}, {109, 169, 240, 255})

    console_c.log("Welcome back, " .. user_name)
    console_c.log("Author: " .. author)
    console_c.log("Type: " .. type)
    console_c.log("Version: " .. version)
end; on_load()
--- @endregion

--- @region: callbacks
--- @callback: paint
callbacks.add("on_paint", watermark_c.handle)
callbacks.add("on_paint", indicators_c.handle)
callbacks.add("on_paint", keybinds_c.handle)
callbacks.add("on_paint", hit_log_c.handle)

--- @callback: createmove
callbacks.add("on_createmove", condition_anti_aim.handle)

--- @callback: frame_net
callbacks.add("on_frame_net", anim_breaker.handle)

--- @callback: unload
callbacks.add("on_unload", function() engine.set_clantag("\0") end)

--- @callback: event
callbacks.add("on_event", hit_log_c.hit_event)

--- @callback: shot
callbacks.add("on_shot", hit_log_c.shot_event)
--- @endregion