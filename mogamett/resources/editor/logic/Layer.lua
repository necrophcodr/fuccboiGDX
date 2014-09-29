Layer = mg.Class:extend('Layer')

function Layer:new(settings)
    self.name = settings.name or 'New Layer'
    self.tileset = settings.tileset or ''
    self.tilesize = settings.tilesize or 32

    self.active = true
end
