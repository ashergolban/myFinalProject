CavernArea = MapBase:extend()

function CavernArea:new(x, y)
    CavernArea.super.new(self, "maps/CaveMap.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)

    self:loadLevers()
    self.objectsImage = love.graphics.newImage("maps/gfx/objects.png")
    local objectsTileWidth, objectsTileHeight = 16, 16

    self.leverLeft = love.graphics.newQuad(2 * objectsTileWidth, 9 * objectsTileHeight, objectsTileWidth, objectsTileHeight, self.objectsImage:getWidth(), self.objectsImage:getHeight())
    self.leverRight = love.graphics.newQuad(3 * objectsTileWidth, 9 * objectsTileHeight, objectsTileWidth, objectsTileHeight, self.objectsImage:getWidth(), self.objectsImage:getHeight())

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernArea:loadLevers()
    local leverLayer = self.map.layers["Levers"]
    if not leverLayer or leverLayer.type ~= "objectgroup"  then
        return
    end

    self.levers = {}

    for _, object in ipairs(leverLayer.objects) do
        if object.name == "difficulty_lever" then
            local lever = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                state = "left",
                isLever = true
            }

            self.world:add(lever, lever.x, lever.y, lever.width, lever.height)

            table.insert(self.levers, lever)
        end
    end
end

function CavernArea:drawBefore()
    CavernArea.super.drawBefore(self)

    for _, lever in ipairs(self.levers) do
        local loadLeverDirection = self.leverLeft
        if lever.state == "left" then
            loadLeverDirection = self.leverLeft
        else
            loadLeverDirection = self.leverRight
        end

        love.graphics.draw(self.objectsImage, loadLeverDirection, lever.x + 2, lever.y)
    end
end

function CavernArea:keypressed(key)
    if key == "space" then
        local px, py, pw, ph = self.world:getRect(self.player)
        local overlaps = self.world:queryRect(px, py, pw, ph)

        for _, lever in ipairs(overlaps) do
            if lever and lever.state then
                if lever.state == "left" then
                    lever.state = "right"
                else
                    lever.state = "left"
                end
            end
        end
    end
end

function CavernArea:switchMap(portal)
    -- Switches the current level with a new instance based of the target map in the portal properties
    -- The player will spawn at the coordinates defined in the portal's properties
    if portal.target_map == "main" then
        currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
    elseif portal.target_map == "death" then
        currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
    elseif portal.target_map == "puzzle1" then
        local difficulty = "easy"
        local roundLives = 3

        for _, lever in ipairs(self.levers) do
            if lever.state == "right" then
                difficulty = "hard"
                break
            end
        end

        currentLevel = CavernPuzzle1(portal.spawn_x, portal.spawn_y, difficulty, roundLives)
    end
end