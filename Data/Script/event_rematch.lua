require 'common'

-- ==============================================================================
function SINGLE_CHAR_SCRIPT.ApplyRematchBoost(owner, ownerChar, context, args)
    if not SV.guildmaster_summit.rematch then return end
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    local cubic_total = 0
    for i=0, player_count-1, 1 do
        cubic_total = cubic_total + _DATA.Save.ActiveTeam.Players[i].Level^3
    end
    local cubic_average = math.floor(((cubic_total/math.min(player_count, 4))^(1/3)) + 0.01)
    local boss_level = math.min(math.max(50, cubic_average), 100)

    local calcBuff = function(minLevel, maxLevel, minBuff, maxBuff, currentLevel)
        if currentLevel<=minLevel then return minBuff end
        if currentLevel>=maxLevel then return maxBuff end
        local currentInRange = currentLevel-minLevel
        local lvlRange = maxLevel-minLevel
        local buffRange = maxBuff-minBuff
        local buffPerLevel = buffRange/lvlRange
        local buffAtLevel = minBuff + buffPerLevel*currentInRange
        return math.floor(buffAtLevel, currentInRange)
    end

    local done = {}
    for char in luanet.each(LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(false, true))) do
        local already_done = false
        for _, c in pairs(done) do
            if char:Equals(c) then
                already_done = true
                break
            end
        end
        if not already_done then
            table.insert(done, char)
            local atkBuff = calcBuff(50, 100, 0,  64, boss_level)
            local othBuff = calcBuff(50, 100, 64, 96, boss_level) -- defenses, speed
            char.Level = boss_level
            char.AtkBonus   = atkBuff
            char.MAtkBonus  = atkBuff
            char.DefBonus   = othBuff
            char.MDefBonus  = othBuff
            char.SpeedBonus = othBuff
            PrintInfo(tostring(char.Level))
        end
    end
end
