local texts = require('texts')
local utility = require('utility')
local defaults = require('defaults')
local config = require('config')

local settings = config.load(defaults)
local get_mob_array = windower.ffxi.get_mob_array
local get_mob_by_target = windower.ffxi.get_mob_by_target
local track_learnable = settings.radar.track_learnable
local track_unlearnable = settings.radar.track_unlearnable

local radar = { visible = false }
local radar_box = texts.new("", settings.radar, settings)

local radar_lines = T{}
local grouped_mobs = {}
local valid_mobs = T{}

local function get_mob_info(mob)
    local is_monster = mob.spawn_type == 16
    local is_valid = mob.valid_target
    local is_alive = mob.hpp > 0
    return is_monster, is_valid, is_alive
end

local function add_to_grouped_mobs(mob, mob_data)
    if not grouped_mobs[mob.name] then
        grouped_mobs[mob.name] ={
            name = mob.name,
            count = 1,
            distance = mob.distance,
            x = mob.x,
            y = mob.y,
            spells = mob_data.spells_string
        }
    else
        grouped_mobs[mob.name].count = grouped_mobs[mob.name].count + 1
        local dist = mob.distance
        if dist < grouped_mobs[mob.name].distance then
            grouped_mobs[mob.name].distance = dist
            grouped_mobs[mob.name].x = mob.x
            grouped_mobs[mob.name].y = mob.y
        end
    end
end

local function group_mobs(nearby_mobs, db_cache)
    for _, mob in pairs(nearby_mobs) do
        local is_monster, is_valid, is_alive = get_mob_info(mob)

        if is_monster and is_valid and is_alive and db_cache[mob.name] then
            local mob_data = utility.compiled_strings[mob.name]

            local should_display = false
            if mob_data then
                if track_learnable and mob_data.has_learnable then should_display = true end
                if track_unlearnable and mob_data.has_unlearnable then should_display = true end
            end

            if should_display then
                add_to_grouped_mobs(mob, mob_data)
            end
        end
    end
end

local function display_top_ten_closest(player_loc)
    valid_mobs:sort(function(a, b) return a.distance < b.distance end)
    local display_count = math.min(10, #valid_mobs)

    for i = 1, display_count do
        local m = valid_mobs[i]
        local name_str = m.name
        if m.count > 1 then
            name_str = string.format("%s x%d", m.name, m.count)
        end

        local dir = utility:get_compass_dir(player_loc.x, player_loc.y, m.x, m.y)

        radar_lines:append(string.format(" %s [%dy %s] -> %s", name_str, math.sqrt(m.distance), dir, m.spells))
    end
end

local function display_settings_all_false()
    radar_lines:append("\\cs(255,100,100)  All radar tracking is disabled\\cr")
    radar_lines:append("\\cs(255,100,100)  Check your settings.xml\\cr")
    radar_box:text(radar_lines:concat('\n'))
    radar_box:show()
end

local function display_no_targets()
    radar_lines:append(" \\cs(180,180,180)No unlearned targets nearby.\\cr")
    radar_box:text(radar_lines:concat('\n'))
    radar_box:show()
end

function radar:update_radar(zoning_bool, db_cache)
    if not self.visible or zoning_bool then return end

    if not utility.player_state.is_blu then
        radar_box:hide()
        return
    end

    radar_lines:clear()
    radar_lines:append(string.format("\\cs(255,225,125)  Nearby Learnable Blue Magic\\cr"))
    radar_lines:append("\\cs(100,100,100)---------------------------------------\\cr")

    -- in case someone flags both as false on accident
    if not track_learnable and not track_unlearnable then
        display_settings_all_false()
        return
    end

    local player_loc = get_mob_by_target('me')
    if not player_loc then return end

    valid_mobs:clear()
    for k in pairs(grouped_mobs) do grouped_mobs[k] = nil end

    local nearby_mobs = get_mob_array()

    group_mobs(nearby_mobs, db_cache)

    for _, m in pairs(grouped_mobs) do
        valid_mobs:append(m)
    end

    if #valid_mobs == 0 then
        display_no_targets()
        return
    end

    display_top_ten_closest(player_loc)

    radar_box:text(radar_lines:concat('\n'))
    radar_box:show()
end

function radar:hide()
    radar_box:hide()
end

return radar