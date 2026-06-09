--[[Copyright © 2026, Shelanoir
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of BBBlu nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SHELANOIR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'BBBlu'
_addon.author = 'Shelanoir'
_addon.version = '1.11'
_addon.commands = {'bbblu'}

local radar = require('radar')
local target_spells = require('target_spells')
local utility = require('utility')
local config = require('config')
local settings = config.load(require('defaults'))

local zoning_bool = false
local last_radar_update = 0
local db_cache

local function update_state()
    if db_cache and windower.ffxi.get_info().logged_in then
        utility:update_player_state()
        utility:compile_mob_strings(db_cache, settings)
    end
end

windower.register_event('load', function()
    db_cache = utility:preload_database()

    if not windower.ffxi.get_info().logged_in then return end
    update_state()

    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    if target then target_spells:get_target(zoning_bool, db_cache) end

end)

windower.register_event('job change', update_state)
windower.register_event('level up', update_state)
windower.register_event('target change', update_state)

windower.register_event('addon command', function(cmd, ...)
    if cmd == 'radar' or cmd == 'toggle' then
        radar.visible = not radar.visible
        if not radar.visible then
            radar:hide()
        else
            update_state()
            radar:update_radar(zoning_bool, db_cache)
        end
        windower.add_to_chat(207, "BBBlu: Radar window " .. (radar.visible and "enabled." or "disabled."))
    end
end)

windower.register_event('prerender', function()
    local now = os.clock()
    if now - last_radar_update > 2 then
        last_radar_update = now
        radar:update_radar(zoning_bool, db_cache)
    end
end)

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if id == 0xB then
        zoning_bool = true
        target_spells:hide()
        radar:hide()
    elseif id == 0xA then
        zoning_bool = false
    end
end)

-- 419: learns, 53: skill up, 9: level up
windower.register_event('action message', function(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    local player = windower.ffxi.get_mob_by_target('me')

    if player and target_id == player.id then
        if message_id == 419 or message_id == 53 or message_id == 9 then
            coroutine.schedule(function()
                if db_cache and windower.ffxi.get_info().logged_in then
                    utility:update_player_state()
                    utility:compile_mob_strings(db_cache, settings)
                end
                
                local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
                if target then
                    target_spells:get_target(zoning_bool, db_cache) 
                end
                
            end, 1.5)
        end

        if message_id == 419 then
            windower.play_sound(windower.addon_path..'sounds/NewSpell.wav')
        end
    end
end)

windower.register_event('target change', function(index)
    target_spells:get_target(zoning_bool, db_cache)
end)
