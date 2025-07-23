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

function CavernPuzzle1:update(dt)
    CavernPuzzle1.super.update(self, dt)

    if self.minesweeperZone then
        local zone = self.minesweeperZone
        local mouseX, mouseY = self.cam:toWorld(love.mouse.getPosition())

        local tileWidth = self.map.tilewidth
        local tileHeight = self.map.tileheight

        selectedX = math.floor((mouseX - zone.x) / tileWidth) + 1
        selectedY = math.floor((mouseY - zone.y) / tileHeight) + 1

        selectedX = math.max(1, math.min(self.cols, selectedX))
        selectedY = math.max(1, math.min(self.rows, selectedY))
    end
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
        local tileWidth = self.map.tilewidth
        local tileHeight = self.map.tileheight

        local startX = zone.x
        local startY = zone.y

        for row = 1, self.rows do
            for col = 1, self.cols do
                local tile = "covered"

                if selectedX == col and selectedY == row then
                    tile = "covered_highlighted"
                end

                local drawX = startX + (col - 1) * tileWidth
                local drawY = startY + (row - 1) * tileHeight

                love.graphics.draw(self.image, self.tiles[tile], drawX, drawY)
            end
        end
        -- Debugging purposes
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", zone.x, zone.y, zone.width, zone.height)
        love.graphics.setColor(1, 1, 1)
    end
    -- Debugging purposes 
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('selected x: '..selectedX..' selected y: '..selectedY)
    love.graphics.setColor(1, 1, 1)
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

    self.imageFrameWidth = imageWidth / 7
    self.imageFrameHeight = imageHeight / 2

    for row = 1, #tileNames do
        for col = 1, #tileNames[row] do
            local key = tileNames[row][col]
            self.tiles[key] = love.graphics.newQuad(
                (col - 1) * self.imageFrameWidth,
                (row - 1) * self.imageFrameHeight,
                self.imageFrameWidth,
                self.imageFrameHeight,
                imageWidth,
                imageHeight
            )
        end
    end

    self:loadMinesweeperArea()
end

function CavernPuzzle1:loadMinesweeperArea()
     -- First look for a layer name "MinesweeperArea" of type "objectgroup" in the map
    local layer = self.map.layers["MinesweeperArea"]
    if not layer or layer.type ~= "objectgroup" then
        return -- No minesweeperarea layer was found, dont load anything
    end

    for _, object in ipairs(layer.objects) do
        if object.name == "minesweeper_zone" then
            self.minesweeperZone = {
            x = object.x,
            y = object.y,
            width = object.width,
            height = object.height
            }

            self.cols = math.floor(self.minesweeperZone.width / self.map.tilewidth)
            self.rows = math.floor(self.minesweeperZone.height / self.map.tileheight)
            break
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