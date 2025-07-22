CavernPuzzle1 = MapBase:extend()

function CavernPuzzle1:new(x, y)
    CavernPuzzle1.super.new(self, "maps/CavePuzzle1.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)
    
    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end

    self:minesweeperFunctionality()
end

function CavernPuzzle1:drawBefore()
    -- Draw only all visible tile layers in the correct order
    for _, layer in ipairs(self.map.layers) do
        if layer.type == "tilelayer" and layer.visible then
            self.map:drawLayer(layer)
        end
    end

    if self.minesweeperZone then
        local zone = self.minesweeperZone
        local tileW = self.map.tilewidth
        local tileH = self.map.tileheight

        local cols = math.floor(zone.width / tileW)
        local rows = math.floor(zone.height / tileH)

        local startX = zone.x
        local starty = zone.y

        for row = 0, rows - 1 do
            for col = 0, cols - 1 do
                love.graphics.draw(self.image, self.tiles["covered"], startX + col * tileW, starty + row * tileH)
            end
        end
    end
end

function CavernPuzzle1:minesweeperFunctionality()
    self.image = love.graphics.newImage("maps/gfx/minesweeper.png")
    local imageWidth = self.image:getWidth()
    local imageHeight = self.image:getHeight()

    local tileNames = {
        {'covered', 'covered_highlighted', 'uncovered', 'skull', 'flag','question', 'one'},
        {'two', 'three', 'four', 'five', 'six', 'seven', 'eight'}
    }

    self.tiles = {}

    local imageFrameWidth = 16
    local imageFrameHeight = 16

    for row = 1, #tileNames do
        for col = 1, #tileNames[row] do
            local key = tileNames[row][col]
            self.tiles[key] = love.graphics.newQuad((col - 1) * imageFrameWidth, (row - 1) * imageFrameHeight, imageFrameWidth, imageFrameHeight, imageWidth, imageHeight)
        end
    end

    for _, layer in ipairs(self.map.layers) do
        if layer.type == "objectgroup" then
            for _, object in ipairs(layer.objects) do
                if object.name == "minesweeper_zone" then
                    self.minesweeperZone = {
                    x = object.x,
                    y = object.y,
                    width = object.width,
                    height = object.height
                    }
                    break
                end
            end
        end
    end
end

function CavernPuzzle1:switchMap(portal)
    -- Switches the current level with a new instance based of the target map in the portal properties
    -- The player will spawn at the coordinates defined in the portal's properties
    if portal.target_map == "cavern" then
        currentLevel = CavernArea(portal.spawn_x, portal.spawn_y)
    end
end