local res = require('resources')
local sqlite3 = require('sqlite3')
local config = require('config')
local defaults = require('defaults')

local utility = {}
utility.settings = config.load(defaults)
local db

local blu_spells = res.spells:type('BlueMagic')

utility.player_state = {
    known_spells = {},
    blue_skill = 0,
    is_blu = false
}

function utility:update_player_state()
    local player = windower.ffxi.get_player()
    if not player then return end

    self.player_state.is_blu = player.main_job == 'BLU' or player.sub_job == 'BLU'
    self.player_state.known_spells = windower.ffxi.get_spells()
    self.player_state.blue_skill = player.skills.blue_magic
end

function utility:compile_mob_strings(db_cache, settings)
    if not db_cache or not settings then return end

    local state = self.player_state
    local c_unlearned = settings.colors.unlearned
    local c_cant_learn = settings.colors.cant_learn

    self.compiled_strings = {} -- need to clear before writing

    for mob_name, spell_list in pairs(db_cache) do
        local unlearned_spells = {}
        local has_learnable = false
        local has_unlearnable = false

        for _, spell in ipairs(spell_list) do
            if spell.id and not state.known_spells[spell.id] then
                local is_skill_locked = spell.min_blue_skill > state.blue_skill

                if is_skill_locked then
                    has_unlearnable = true
                    table.insert(unlearned_spells, string.format("\\cs(%d,%d,%d)%s\\cr", c_cant_learn.red, c_cant_learn.green, c_cant_learn.blue, spell.name))
                else
                    has_learnable = true
                    table.insert(unlearned_spells, string.format("\\cs(%d,%d,%d)%s\\cr", c_unlearned.red, c_unlearned.green, c_unlearned.blue, spell.name))
                end
            end
        end

        if #unlearned_spells > 0 then
            self.compiled_strings[mob_name] = {
                spells_string = table.concat(unlearned_spells, ', '),
                has_learnable = has_learnable,
                has_unlearnable = has_unlearnable
            }
        end
    end
end

function utility:get_compass_dir(p_x, p_y, m_x, m_y)
    local dx = m_x - p_x
    local dy = m_y - p_y
    -- +X is east, +Y is north
    local angle = math.floor(math.deg(math.atan2(dy, dx)))

    -- convert standard math degrees to compass degrees (0=North, 90=East)
    local compass_deg = (90 - angle + 360) % 360

    local dirs = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
    local index = math.floor(((compass_deg + 22.5) % 360) / 45) + 1
    return dirs[index]
end


-- preload the database
function utility:preload_database()
    local db_cache = {}
    local db_cache_by_location = {}
    db = sqlite3.open(windower.addon_path..'/database.db')

    local spell_name_to_id = {}
    for _, v in pairs(blu_spells) do
        spell_name_to_id[v.english] = v.id
    end

    local stmt = db:prepare([[
        SELECT m.name AS mob_name, s.name AS spell_name, s.min_blue_skill, l.name as location_name
        FROM spells s
        JOIN monster_spells ms ON s.id = ms.spell_id
        JOIN monsters m on m.id = ms.monster_id
        JOIN monster_locations ml on m.id = ml.monster_id
        JOIN locations l on l.id = ml.location_id
    ]])

    for row in stmt:nrows() do
        if not db_cache[row.mob_name] then
            db_cache[row.mob_name] = T{}
        end
        local true_spell_id = spell_name_to_id[row.spell_name]
        
        local already_has_spell = false
        for _, spell in ipairs(db_cache[row.mob_name]) do
            if spell.id == true_spell_id then
                already_has_spell = true
                break
            end
        end

        if not already_has_spell then
            db_cache[row.mob_name]:append({
                name = row.spell_name,
                min_blue_skill = row.min_blue_skill,
                id = true_spell_id
            })
        end

        if row.location_name then
            if not db_cache_by_location[row.location_name] then
                db_cache_by_location[row.location_name] = T{}
            end
            
            local loc_has_spell = false
            for _, entry in ipairs(db_cache_by_location[row.location_name]) do
                if entry.mob_name == row.mob_name and entry.spell_name == row.spell_name then
                    loc_has_spell = true
                    break
                end
            end
            
            if not loc_has_spell then
                db_cache_by_location[row.location_name]:append({
                    mob_name = row.mob_name,
                    spell_name = row.spell_name,
                    min_blue_skill = row.min_blue_skill,
                    id = true_spell_id
                })
            end
        end
    end
    stmt:finalize()
    
    if db and db:isopen() then
        db:close()
    end

    return db_cache, db_cache_by_location
end

return utility