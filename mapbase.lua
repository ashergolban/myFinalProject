MapBase = Object:extend()

function MapBase:new(mapFile)
    self.map = sti(mapFile, { "bump" })
    self.world = bump.newWorld()
    self.map:bump_init(self.world)
    self:loadPortals()

    self.width = self.map.width * self.map.tilewidth
    self.height = self.map.height * self.map.tileheight
    self.cam = gamera.new(0, 0, self.width, self.height) -- Sets the boundaries of the camera
    self.cam:setScale(4) -- Scales the camera to be more zoomed in
end

function MapBase:update(dt)
    self.map:update(dt)
    self.player:update(dt)

    local camX = self.player.x + self.player.frameWidth / 2
    local camY = self.player.y + self.player.frameHeight / 2
    self.cam:setPosition(camX, camY)
end

function MapBase:draw()
    self.cam:draw(function(l, t, w, h)
        self:drawBefore()
        self.player:draw()

        if showDebug then
            self:drawDebug()
        end
    end)
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

function MapBase:loadPortals()
    self.portals = {}

    local layer = self.map.layers["Portals"]
    if not layer or layer.type ~= "objectgroup" then
        return
    end

    for _, obj in ipairs(layer.objects) do
        local portal = {
            x = obj.x,
            y = obj.y,
            width = obj.width,
            height = obj.height,
            target_map = obj.properties.target_map,
            spawn_x = obj.properties.spawn_x,
            spawn_y = obj.properties.spawn_y,
            isPortal = true
        }

        self.world:add(portal, portal.x, portal.y, portal.width, portal.height)

        table.insert(self.portals, portal)
    end
end