require 'common'

-- ==============================================================================
function SINGLE_CHAR_SCRIPT.ApplyRematchBoost(owner, ownerChar, context, args)
    if not SV.guildmaster_summit.rematch then return end
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    local standard_count = math.min(player_count, 4)
    local max_level = 0
    for i=0, player_count-1, 1 do
        max_level = math.max(_DATA.Save.ActiveTeam.Players[i].Level, max_level)
    end
    local count_multiplier = ((player_count-standard_count)/8)+1
    local final_count = max_level*count_multiplier + SV.guildmaster_summit.victories
    if (final_count % 1) >= 0.5
    then final_count = math.ceil(final_count)
    else final_count = math.floor(final_count)
    end
    local boss_level = math.min(math.max(50, final_count), 100)
    

    local calcBuff = function(minLevel, maxLevel, minBuff, buffAtMax, currentLevel)
        if currentLevel<=minLevel then return minBuff end
        local currentInRange = currentLevel-minLevel
        local lvlRange = maxLevel-minLevel
        local buffRange = buffAtMax-minBuff
        local buffPerLevel = buffRange/lvlRange
        local buffAtLevel = minBuff + buffPerLevel*currentInRange
        return math.min(math.floor(buffAtLevel), 256)
    end

    for char in luanet.each(LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(false, true))) do
        if char.Level ~= boss_level then
            local atkBuff = calcBuff(50, 100, 0,  64,  final_count)
            local otherBuff = calcBuff(50, 100, 64, 96, final_count)
            char.Level = boss_level
            char.HP    = char.MaxHP
            char.AtkBonus   = atkBuff
            char.MAtkBonus  = atkBuff
            char.DefBonus   = otherBuff
            char.MDefBonus  = otherBuff
            char.SpeedBonus = otherBuff
        end
    end
end
