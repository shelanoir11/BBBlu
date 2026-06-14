local texts = require('texts')
local utility = require('utility')
local settings = utility.settings

local target_spells = {}
target_spells.visible = false

local box = texts.new(settings.display, settings)

function target_spells:get_spells(target_name, db_cache)
    if not db_cache[target_name] then
        box:hide()
        return
    end

    local lines = T{}
    lines:append(string.format("\\cs(255,225,125)  Learnable Blue Magic\\cr"))
    lines:append("\\cs(100,100,100)---------------------------------------\\cr")
    
    -- fetch the player's known spells
    local known_spells = utility.player_state.known_spells
    local blue_skill_level = utility.player_state.blue_skill

    local found = false

    -- grab the colors from the loaded settings
    local c_learned = settings.colors.learned
    local c_unlearned = settings.colors.unlearned
    local c_cant_learn = settings.colors.cant_learn

    local listed_spells = T{}

    for _, row in ipairs(db_cache[target_name] or {}) do
        found = true
        local is_already_listed = false
        for _, listed in ipairs(listed_spells) do
            if row.id == listed then
                is_already_listed = true
            end
        end
        if not is_already_listed then
            if row.id and known_spells[row.id] then
                -- learned spells: uses the custom 'learned' color
                lines:append(string.format("\\cs(%d,%d,%d)  %s (Skill: %d+)\\cr", c_learned.red, c_learned.green, c_learned.blue, row.name, row.min_blue_skill))
            elseif row.min_blue_skill > blue_skill_level then
                -- can't learn yet: uses the custom 'can't learn' color
                lines:append(string.format("\\cs(%d,%d,%d)  %s (Skill: %d+)\\cr", c_cant_learn.red, c_cant_learn.green, c_cant_learn.blue, row.name, row.min_blue_skill))
            else
                -- unlearned spells: uses the custom 'unlearned' color
                lines:append(string.format("\\cs(%d,%d,%d)  %s (Skill: %d+)\\cr", c_unlearned.red, c_unlearned.green, c_unlearned.blue, row.name, row.min_blue_skill))
            end
        end
        if row.id then
            listed_spells:append(row.id)
        end
    end

    if found then
        box:text(lines:concat('\n'))
        box:show()
    else
        box:hide()
    end
end

function target_spells:get_target(zoning_bool, db_cache)
    if zoning_bool then
        box:hide()
        return
    end

    -- check if the player is a blue mage (main or sub)
    if not utility.player_state.is_blu then
        box:hide()
        return
    end

    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    
    -- spawn_type 16 designates targetable enemy mobs
    if target and target.spawn_type == 16 then
        self:get_spells(target.name, db_cache)
    else
        box:hide()
    end
end


function target_spells:hide()
    box:hide()
end

return target_spells