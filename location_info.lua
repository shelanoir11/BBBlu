local res = require('resources')
local texts = require('texts')
local utility = require('utility')
local settings = utility.settings

local track_learnable = settings.radar.track_learnable
local track_unlearnable = settings.radar.track_unlearnable

local location_info = { visible = settings.show_location }

local location_box = texts.new(settings.location, settings)

local location_lines = T{}

local function display_settings_all_false()
    location_lines:append("\\cs(255,100,100)  All spell tracking is disabled\\cr")
    location_lines:append("\\cs(255,100,100)  Check your settings.xml\\cr")
    location_box:text(location_lines:concat('\n'))
    location_box:show()
end

function location_info:get_info(zoning_bool, db_cache_by_location)
    if not self.visible or zoning_bool then return end

    if not utility.player_state.is_blu then
        location_box:hide()
        return
    end

    location_lines:clear()
    
    local info = windower.ffxi.get_info()
    if not info then return end
    
    local current_zone = res.zones[info.zone].english
    current_zone = current_zone:gsub("%[S%]", "%(S%)")
    windower.add_to_chat(207, current_zone)

    location_lines:append(string.format("\\cs(255,225,125)  %s Blue Magic\\cr", current_zone))
    location_lines:append("\\cs(100,100,100)---------------------------------------\\cr")

    if not track_learnable and not track_unlearnable then
        display_settings_all_false()
        return
    end

    local zone_data = db_cache_by_location[current_zone]

    -- If no data for this zone, show a blank state
    if not zone_data or #zone_data == 0 then
        location_lines:append(" \\cs(180,180,180)No learnable spells in this zone.\\cr")
        location_box:text(location_lines:concat('\n'))
        location_box:show()
        return
    end

    local known_spells = utility.player_state.known_spells
    local blue_skill_level = utility.player_state.blue_skill

    local c_unlearned = settings.colors.unlearned
    local c_cant_learn = settings.colors.cant_learn

    local spells_in_zone = {}
    local ordered_spells = T{}

    -- Process the zone cache to filter knowns and group by spell
    for _, entry in ipairs(zone_data) do
        if entry.id and not known_spells[entry.id] then
            local is_skill_locked = entry.min_blue_skill > blue_skill_level
            local should_track = (is_skill_locked and track_unlearnable) or (not is_skill_locked and track_learnable)
            
            if should_track then
                if not spells_in_zone[entry.spell_name] then
                    spells_in_zone[entry.spell_name] = {
                        min_skill = entry.min_blue_skill,
                        is_locked = is_skill_locked,
                        mobs = T{}
                    }
                    ordered_spells:append(entry.spell_name)
                end
                
                -- Prevent duplicate mob names on the same spell
                if not spells_in_zone[entry.spell_name].mobs:contains(entry.mob_name) then
                    spells_in_zone[entry.spell_name].mobs:append(entry.mob_name)
                end
            end
        end
    end

    if #ordered_spells == 0 then
        location_lines:append(" \\cs(180,180,180)No unlearned targets in this zone.\\cr")
        location_box:text(location_lines:concat('\n'))
        location_box:show()
        return
    end

    -- Build the UI lines
    for _, spell_name in ipairs(ordered_spells) do
        local s_data = spells_in_zone[spell_name]
        local c = s_data.is_locked and c_cant_learn or c_unlearned
        local c_format = string.format("\\cs(%d,%d,%d)", c.red, c.green, c.blue)
        
        location_lines:append(string.format("%s  %s (Skill: %d+)\\cr", c_format, spell_name, s_data.min_skill))
        
        local mob_string = string.format("    %s%s\\cr", c_format, s_data.mobs:concat(', '))
        location_lines:append(mob_string)
    end

    location_box:text(location_lines:concat('\n'))
    location_box:show()
end

function location_info:hide()
    location_box:hide()
end

return location_info