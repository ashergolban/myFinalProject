MapBase = Object:extend()

function MapBase:new(mapFile)
    self.map = sti(mapFile, { "bump" })
    self.world = bump.newWorld()
    self.map:bump_init(self.world)

    self.width = self.map.width * self.map.tilewidth
    self.height = self.map.height * self.map.tileheight
    self.cam = gamera.new(0, 0, self.width, self.height) -- Sets the boundaries of the camera
    self.cam:setScale(4) -- Scales the camera to be more zoomed in
end

function MapBase:update(dt)
    self.map:update(dt)
end

function MapBase:drawBefore()
    for _, layer in ipairs(self.map.layers) do
        if layer.type == "tilelayer" and layer.visible then
            self.map:drawLayer(layer)
        end
    end
end

function MapBase:drawDebug()
    if showDebug then
        for _, item in pairs(self.world:getItems()) do
            local x, y, w, h = self.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)
        end
    end
end