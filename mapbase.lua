MapBase = Object:extend()

-- Base class for creating maps
function MapBase:new(mapFile)
    -- Intialize the map with the sti library with the Bump plugin for collisions
    self.map = sti(mapFile, { "bump" })  
    self.world = bump.newWorld() -- Create a new bump collision world
    self.map:bump_init(self.world)  -- Intialize Bump for use with the STI map
    self:loadPortals() -- Function to load portal objects from the map and add them to the world

    -- Calculate the map dimensions in pxiels 
    -- and initialize a camera with the boundaries matching the map size
    self.width = self.map.width * self.map.tilewidth
    self.height = self.map.height * self.map.tileheight
    self.cam = gamera.new(0, 0, self.width, self.height)
    self.cam:setScale(4) -- Set the camera with a 4x zoom
end

function MapBase:update(dt)
    -- Update the map if there are animated tiles
    -- and update the player's movement and animation
    self.map:update(dt)
    self.player:update(dt)

    -- Update the camera to follow the player's centre position
    local camX = self.player.x + self.player.frameWidth / 2
    local camY = self.player.y + self.player.frameHeight / 2
    self.cam:setPosition(camX, camY)
end

function MapBase:draw()
    -- Draw everything relative to the camera
    self.cam:draw(function(l, t, w, h)
        -- Draw the map layers before the player and then draw the player sprite
        self:drawBefore()
        self.player:draw()

        -- Draw debug rectangles for collision boxes if the key is pressed
        if showDebug then
            self:drawDebug()
        end
    end)
end

function MapBase:drawBefore()
    -- Draw only all visible tile layers in the correct order
    for _, layer in ipairs(self.map.layers) do
        if layer.type == "tilelayer" and layer.visible then
            self.map:drawLayer(layer)
        end
    end
end

function MapBase:drawDebug()
    -- If debug mode is enabled, draw collision boxes around all objects in the world
    if showDebug then
        for _, item in pairs(self.world:getItems()) do
            local x, y, w, h = self.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)
        end
    end
end

function MapBase:loadPortals()
    -- Initialize an empty list to hold all portal objects
    self.portals = {}

    -- First look for a layer name "Portals" of type "objectgroup" in the map
    local layer = self.map.layers["Portals"]
    if not layer or layer.type ~= "objectgroup" then
        return -- No portal layer was found, dont load anything
    end

    -- Loop through each object in the portal layer and set up the portal
    for _, obj in ipairs(layer.objects) do
        local portal = {
            x = obj.x,
            y = obj.y,
            width = obj.width,
            height = obj.height,
            target_map = obj.properties.target_map, -- The map to switch too
            spawn_x = obj.properties.spawn_x, -- X position to spawn in the new map
            spawn_y = obj.properties.spawn_y, -- Y position to spawn in the new map
            isPortal = true --Flag to identify this is a portal
        }

        -- Add the protal to the collision world so the player can detect it
        self.world:add(portal, portal.x, portal.y, portal.width, portal.height)

        -- Store the portal in the table
        table.insert(self.portals, portal)
    end
end