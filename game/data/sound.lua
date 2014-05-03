sounds = {}

-- Most sounds are defined here. Simply add the name of the sound (as it is in the resources/sounds folder)
-- to the appropriate event and it will happen in game. Having more than one sound, like this:
-- sounds['lalala'] = {'foo', 'bar'}, will choose sounds resources/sounds/foo.ogg or resources/sounds/bar.ogg at random
-- whenever event 'lalala' happens in the game.
--
-- Right now this is super limited and quite literally only plays sounds in a very simple manner
-- but I plan on adding more controls later.



-- Player
sounds['Player Hurt'] = {}
sounds['Player Jump'] = {}
sounds['Player Walk'] = {repeat_interval = 0.5, volume = 0.5}
sounds['Player Shield'] = {}
sounds['Player Ladder Climb'] = {repeat_interval = 0.5}
sounds['Player Death'] = {}
sounds['Player Attack'] = {}

-- Explosions
sounds['TNT Explosion'] = {}
sounds['Enemy Explosion'] = {}
sounds['PumperProjectile Explosion'] = {}

-- Melee Attack
sounds['Melee Player->Enemy Hit'] = {}
sounds['Melee Player->TNT Hit'] = {}
sounds['Melee Player->BreakableSolid Hit'] = {}

-- Hammer
sounds['Hammer->Enemy Hit'] = {}
sounds['Hammer->PumperProjectile Hit'] = {}
sounds['Hammer->TNT Hit'] = {}
sounds['Hammer->BreakableSolid Hit'] = {}
sounds['Hammer->Solid Hit'] = {}

-- PumperProjectile
sounds['PumperProjectile->Solid Hit'] = {}
sounds['PumperProjectile Movement'] = {repeat_interval = 0.1}

-- Boulder
sounds['Boulder->Solid Hit'] = {}
sounds['Boulder->TNT Hit'] = {}
sounds['Boulder->BreakableSolid Hit'] = {}

-- Other
sounds['SpikedBall->BreakableSolid Hit'] = {}
sounds['JumpingPad Activate'] = {}
sounds['Button Activate'] = {}



-- Ignore this...
for k, v in pairs(sounds) do
    for i, j in ipairs(v) do
        if type(i) == 'number' then
            sounds[k][i] = "resources/sounds/" .. sounds[k][i] .. ".ogg"
        end
    end
end
