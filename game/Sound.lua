Sound = class('Sound')

function Sound:init()
    self.sounds = {}
    for k, v in pairs(sounds) do
        self.sounds[k] = {}
        for l, m in pairs(v) do
            if type(l) == 'number' then table.insert(self.sounds[k], m) end
        end
    end
end

function Sound:update(dt)
    TEsound.cleanup()
end

function Sound:play(name)
    if #self.sounds[name] > 0 then TEsound.play(self.sounds[name], "", sounds[name].volume) end
end
