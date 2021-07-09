-- local variables for API functions. any changes to the line below will be lost on re-generation
local entity_get_local_player, entity_is_alive, globals_frametime, math_max, math_min, ui_get, ui_reference, select, ui_set, ui_set_callback, unpack, ui_set_visible = entity.get_local_player, entity.is_alive, globals.frametime, math.max, math.min, ui.get, ui.reference, select, ui.set, ui.set_callback, unpack, ui.set_visible

local anti_aim = require 'gamesense/antiaim_funcs'
local easing = require 'gamesense/easing'

local ref = {
    quick_peek = {ui_reference('Rage', 'Other', 'Quick peek assist')},
    quick_peek_mode = {ui_reference('Rage', 'Other', 'Quick peek assist mode')}
}

local script = {
    path = {'Visuals', 'Effects'},
    charged = 0,
    alpha = select(4, ui_get(ref.quick_peek_mode[2])),
}

function script:create(func, ...)
    local args = {script.path[1], script.path[2], ...}
    return func(unpack(args))
end

local function clamp(val, min, max)
    return math_min(max, math_max(min, val))
end

local lua_ui = {
    enabled = script:create(ui.new_checkbox, 'Animated quick peek'),
    speed = script:create(ui.new_slider, '\nAnimated quick peek speed', 1, 18, 5, true, 'fr'),
}

local function on_paint()
    local me = entity_get_local_player()
    
    if not ui_get(ref.quick_peek[1]) or not ui_get(ref.quick_peek[2]) or not entity_is_alive(me) then
        return
    end

    local eased = easing.sine_in(script.charged, 0, 1, 1)
    local color = {255 - 255 * eased, 255 * eased, 0}

    ui_set(ref.quick_peek_mode[2], color[1], color[2], color[3], script.alpha)

    local FT = globals_frametime() * ui_get(lua_ui.speed)
    local doubletap = anti_aim.get_double_tap()

    script.charged = clamp(script.charged + (doubletap and FT or -FT), 0, 1)
end

function lua_ui:handle_callbacks()
    local enabled = ui_get(self.enabled)
    local update_callback = enabled and client.set_event_callback or client.unset_event_callback
    
    update_callback('paint', on_paint)
    ui_set_visible(lua_ui.speed, enabled)
end

ui_set_callback(lua_ui.enabled, function()
    lua_ui:handle_callbacks()
end)

ui_set_callback(ref.quick_peek_mode[2], function(elem)
    script.alpha = select(4, ui_get(elem))
end)

lua_ui:handle_callbacks()