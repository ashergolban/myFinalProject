CavernPuzzle1 = MapBase:extend()

function CavernPuzzle1:new(x, y)
    CavernPuzzle1.super.new(self, "maps/CavePuzzle1.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)
    
    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function (_, portal)
        self:switchMap(portal)
    end

    self:minesweeperFunctionality()

    self.player.onRevealTile = function (_, tile)
        self:revealTile(tile)
    end

    self.firstTileRevealed = false
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

        for _, cell in ipairs(self.minesweeperTiles) do
            local function drawTile(tile, cell)
                love.graphics.draw(self.image, self.tiles[tile], cell.x, cell.y)
            end

            if not cell.uncovered then
                local tile = "covered"
                if selectedX == cell.col and selectedY == cell.row then
                    tile = "covered_highlighted"
                end

                drawTile(tile, cell)

                if cell.flagged then
                    drawTile("flag", cell)
                elseif cell.questioned then
                    drawTile("question", cell)
                end
            else
                if cell.hasSkull then
                    drawTile("skull", cell)
                else
                    drawTile("uncovered", cell)
                    if cell.nearbySkullCount and cell.nearbySkullCount > 0 then
                        local numberNames = {
                            [1] = "one",
                            [2] = "two",
                            [3] = "three",
                            [4] = "four",
                            [5] = "five",
                            [6] = "six",
                            [7] = "seven",
                            [8] = "eight"
                        }

                        local numName = numberNames[cell.nearbySkullCount]

                        if numName then
                            drawTile(numName, cell)
                        end
                    end
                end
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

    self.minesweeperTiles = {}

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

    if not self.minesweeperZone then
        return
    end

    for _, object in ipairs(layer.objects) do
        if object.name == "minesweeper_tile" then
            local tile = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                col = math.floor((object.x - self.minesweeperZone.x) / self.map.tilewidth) + 1,
                row = math.floor((object.y - self.minesweeperZone.y) / self.map.tileheight) + 1,
                uncovered = false,
                flagged = false,
                questioned = false,
                isMinesweeperTile = true,
                hasSkull = false,
                nearbySkullCount = 0
            }

            self.world:add(tile, tile.x, tile.y, tile.width, tile.height)

            table.insert(self.minesweeperTiles, tile)
        end
    end

    table.sort(self.minesweeperTiles, function (a, b)
        if a.row == b.row then
            return a.col < b.col
        else
            return a.row < b.row
        end
    end)

    self:buildTileGrid()
end

function CavernPuzzle1:buildTileGrid()
    self.tileGrid = {}

    for _, tile in ipairs(self.minesweeperTiles) do
        self.tileGrid[tile.row] = self.tileGrid[tile.row] or {}
        self.tileGrid[tile.row][tile.col] = tile
    end
end

function CavernPuzzle1:placeSkulls(startingTile)
    local skullCount = 40
    local placedSkulls = 0
    local usedSkullPositions = {}

    while placedSkulls < skullCount do
        local index = love.math.random(#self.minesweeperTiles)
        local currentTile = self.minesweeperTiles[index]

        if not usedSkullPositions[index] and not (currentTile.row == startingTile.row and currentTile.col == startingTile.col) then
            usedSkullPositions[index] = true
            currentTile.hasSkull = true
            placedSkulls = placedSkulls + 1
        end
    end

    for _, tile in ipairs(self.minesweeperTiles) do
        local surroundingskullCount = 0

        for _, adjacentTile in ipairs(self:getAdjacentTiles(tile)) do
            if adjacentTile.hasSkull then
                surroundingskullCount = surroundingskullCount + 1
            end
        end
        tile.nearbySkullCount = surroundingskullCount
    end
end

function CavernPuzzle1:revealTile(tile)
    if tile.uncovered or tile.flagged then
        return
    end

    if not self.firstTileRevealed then
        self:placeSkulls(tile)
        self.firstTileRevealed = true
    end

    if tile.hasSkull then
        print("Dead")
        -- Need to work on the gameover and death logic
        tile.uncovered = true
        return
    end

    local stack = { tile }

    while #stack > 0 do
        local currentTile = table.remove(stack)
        if not currentTile.uncovered then
            currentTile.uncovered = true

            if currentTile.nearbySkullCount == 0 and not currentTile.questioned then
                for _, adjacentTile in ipairs(self:getAdjacentTiles(currentTile)) do
                    if adjacentTile and not adjacentTile.uncovered and not adjacentTile.flagged and not adjacentTile.hasSkull then
                        table.insert(stack, adjacentTile)
                    end
                end
            end
        end
    end
end

function CavernPuzzle1:getAdjacentTiles(tile)
    local adjacentTiles = {}

    for dy = -1, 1 do
        for dx = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local adjacentRow = tile.row + dy
                local adjacentCol = tile.col + dx
                if self.tileGrid[adjacentRow] and self.tileGrid[adjacentRow][adjacentCol] then
                    table.insert(adjacentTiles, self.tileGrid[adjacentRow][adjacentCol])
                end
            end
        end
    end
    return adjacentTiles
end

function CavernPuzzle1:mousePressed(x, y, button)
    if button == 2 and selectedX and selectedY then
        for _, tile in ipairs(self.minesweeperTiles) do
            if tile.col == selectedX and tile.row == selectedY and not tile.uncovered then
                if not tile.flagged and not tile.questioned then
                    tile.flagged = true
                elseif  tile.flagged then
                    tile.flagged = false
                    tile.questioned = true
                elseif tile.questioned  then
                    tile.questioned = false
                end
                break
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