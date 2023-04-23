--RAZER MASK
local ffi = require("ffi")
local bit = require("bit")
 
local __thiscall = function(func, this)
    return function(...) return func(this, ...) end
end
local interface_ptr = ffi.typeof("void***")


local vtable_bind = function(module, interface, index, typedef)
    local addr = ffi.cast("void***", se.create_interface(module, interface)) or error(interface .. " was not found")
    return __thiscall(ffi.cast(typedef, addr[0][index]), addr)
end


local vtable_entry = function(instance, i, ct)
    return ffi.cast(ct, ffi.cast(interface_ptr, instance)[0][i])
end


local vtable_thunk = function(i, ct)
    local t = ffi.typeof(ct)
    return function(instance, ...)
        return vtable_entry(instance, i, t)(instance, ...)
    end
end



local get_class_name = vtable_thunk(143, "const char*(__thiscall*)(void*)")

local set_model_index = vtable_thunk(75, "void(__thiscall*)(void*,int)")


local get_client_entity_from_handle = vtable_bind("client.dll", "VClientEntityList003", 4, "void*(__thiscall*)(void*,void*)")

local get_model_index = vtable_bind("engine.dll", "VModelInfoClient004", 2, "int(__thiscall*)(void*, const char*)")


local rawientitylist = se.create_interface('client.dll', 'VClientEntityList003') or error('VClientEntityList003 was not found', 2)
local ientitylist = ffi.cast(interface_ptr, rawientitylist) or error('rawientitylist is nil', 2)

local get_client_entity = ffi.cast('void*(__thiscall*)(void*, int)', ientitylist[0][3]) or error('get_client_entity was not found', 2)


local client_string_table_container = ffi.cast(interface_ptr, se.create_interface('engine.dll', 'VEngineClientStringTable001')) or error('VEngineClientStringTable001 was not found', 2)
local find_table = vtable_thunk(3, 'void*(__thiscall*)(void*, const char*)')


local model_info = ffi.cast(interface_ptr, se.create_interface('engine.dll', 'VModelInfoClient004')) or error('VModelInfoClient004 wasnt found', 2)


ffi.cdef [[
    typedef void(__thiscall* find_or_load_model_t)(void*, const char*);
]]


local add_string = vtable_thunk(8, "int*(__thiscall*)(void*, bool, const char*, int length, const void* userdata)")

local find_or_load_model = ffi.cast("find_or_load_model_t", model_info[0][43]) -- vtable thunk crashes (?)

local function _precache(szModelName)
    if szModelName == "" then return end -- don't precache empty strings (crash)
    if szModelName == nil then return end
    szModelName = string.gsub(szModelName, [[\]], [[/]])

    local m_pModelPrecacheTable = find_table(client_string_table_container, "modelprecache")
    if m_pModelPrecacheTable ~= nil then
        find_or_load_model(model_info, szModelName)
        add_string(m_pModelPrecacheTable, false, szModelName, -1, nil)
    end
end


local changer = {}


changer.list_names = {'None', 'Dallas Dvijenie',}
changer.models = {'', 'models/player/holiday/facemasks/facemask_dallas.mdl',}

changer.last_model = 0
changer.model_index = -1
changer.enabled = false


local combobox_masks = ui.add_combo_box("Current mask", "lua_mask", changer.list_names, 0)


local function precache(modelPath)
    if modelPath == "" then return -1 end -- don't crash.
    local local_model_index = get_model_index(modelPath)
    if local_model_index == -1 then
        _precache(modelPath)
    end
    return get_model_index(modelPath)
end

local function on_paint()
    if not engine.is_in_game() then
        changer.last_model = 0
        return
    end
    if changer.last_model ~= combobox_masks:get_value() then
        changer.last_model = combobox_masks:get_value()
        if changer.last_model == 0 then
            changer.enabled = false
        else
            changer.enabled = true
            changer.model_index = precache(changer.models[changer.last_model + 1])
        end
    end
end


local function get_player_address(lp)
    return get_client_entity(ientitylist, lp:get_index())
end


local function on_setup_command(cmd)
    if changer.model_index == -1 then return precache(changer.models[changer.last_model + 1]) end

    local local_player = entitylist.get_local_player()
    if changer.enabled then
        local lp_addr = ffi.cast("intptr_t*", get_player_address(local_player))
        local m_AddonModelsHead = ffi.cast("intptr_t*", lp_addr + 0x462F) -- E8 ? ? ? ? A1 ? ? ? ? 8B CE 8B 40 10
        local i, next_model = m_AddonModelsHead[0], -1

        while i ~= -1 do
            next_model = ffi.cast("intptr_t*", lp_addr + 0x462C)[0] + 0x18 * i -- this is the pModel (CAddonModel) afaik
            i = ffi.cast("intptr_t*", next_model + 0x14)[0]
            local m_pEnt = ffi.cast("intptr_t**", next_model)[0] -- CHandle<C_BaseAnimating> m_hEnt -> Get()
            local m_iAddon = ffi.cast("intptr_t*", next_model + 0x4)[0]
            if tonumber(m_iAddon) == 16 then -- face mask addon bits knife = 10
                local entity = get_client_entity_from_handle(m_pEnt)
                set_model_index(entity, changer.model_index)
            end
        end
    end
end


local m_iAddonBits = se.get_netvar("DT_CSPlayer", "m_iAddonBits")

client.register_callback("create_move", function()
    local local_player = entitylist.get_local_player()
    if local_player == nil then return end
    if changer.enabled then
        if bit.band(local_player:get_prop_int(m_iAddonBits), 0x10000) ~= 0x10000 then
            local_player:set_prop_int(m_iAddonBits, 0x10000 + local_player:get_prop_int(m_iAddonBits))
        end
    else
        if bit.band(local_player:get_prop_int(m_iAddonBits), 0x10000) == 0x10000 then
            local_player:set_prop_int(m_iAddonBits, local_player:get_prop_int(m_iAddonBits) - 0x10000)
        end
    end
end)

client.register_callback('paint', on_paint)
client.register_callback("create_move", on_setup_command)