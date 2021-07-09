-- Copyright © 2021 Sauron Corporation. All rights reserved.
-- Author: Kaynel der bo$$

local entity = require 'gamesense/entity'

local ref = {
    ping_spike = ui.reference( 'Misc', 'Miscellaneous', 'Ping spike')
}

local script = {
    path = {'Misc', 'Miscellaneous'},
    idx_to_name = {
        [9] = 'AWP',
        [40] = 'Scout',
        [31] = 'Zeus',
        [64] = 'Revolver'
    }
}

function script:create(func, ...)
    local args = {script.path[1], script.path[2], ...}
    return func(unpack(args))
end

local function contains(tbl, val)
	for k, v in pairs(tbl) do
		if v == val then
			return true
		end
	end

    return false
end

local lua_ui = {
    enabled = script:create(ui.new_checkbox, 'Adaptive ping weapons'),
    weapons_list = script:create(ui.new_multiselect, 'Ping weapons', { 'AWP', 'Scout', 'Zeus', 'Revolver' })
}

local function on_setup_command()
	local me = entity.get_local_player()
    local weapon_ent = me:get_player_weapon()

    if weapon_ent == nil then 
        return 
    end

    local weapon = weapon_ent:get_weapon_info()

	if weapon == nil then 
        return 
    end
    
    local weapons_list = ui.get(lua_ui.weapons_list)
    
    ui.set(ref.ping_spike, contains(weapons_list, script.idx_to_name[weapon.idx]))
end

function lua_ui:handle_callbacks()
    local enabled = ui.get(self.enabled)
    local update_callback = enabled and client.set_event_callback or client.unset_event_callback
    
    update_callback('setup_command', on_setup_command)
    ui.set_visible(lua_ui.weapons_list, enabled)
end

ui.set_callback(lua_ui.enabled, function()
    lua_ui:handle_callbacks()
end)

lua_ui:handle_callbacks()
