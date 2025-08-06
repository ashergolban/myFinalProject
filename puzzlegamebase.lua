PuzzleGameBase = MapBase:extend()

function PuzzleGameBase:drawBefore()
    PuzzleGameBase.super.drawBefore(self)

    -- Draw each tile with the correct graphic based on its state
    for _, tile in ipairs(self.puzzleTiles) do
        local loadPuzzleTile = self.puzzleTile[tile.state]
        love.graphics.draw(self.puzzleTilesImage, loadPuzzleTile, tile.x, tile.y)
    end

    -- Draw each button with the correct graphic based on its state
    for _, tile in ipairs(self.buttons) do
        local loadButtonState = self.buttonState[tile.state]
        love.graphics.draw(self.objectsImage, loadButtonState, tile.x + 1, tile.y + 1)
    end
end

function PuzzleGameBase:update(dt)
    PuzzleGameBase.super.update(self, dt)

    self:updateTileState()
    self:buttonFunctionality()
end

function PuzzleGameBase:buttonFunctionality()
    if not self.buttons then
        return
    end

    local playerX, playerY, playerWidth, playerHeight = self.world:getRect(self.player)
    local overlaps = self.world:queryRect(playerX, playerY, playerWidth, playerHeight)

    for _, button in ipairs(self.buttons) do
        local isPressed = false

        for _, object in ipairs(overlaps) do
            if object == button then
                isPressed = true
                break
            end
        end

        if isPressed then
            if button.state ~= "down" then
                self:checkWinCondition()
            end
            button.state = "down"
        else
            button.state = "up"
        end
    end
end

function PuzzleGameBase:updateTileState()
    if not self.puzzleTiles then
        return
    end

    local playerX, playerY, playerWidth, playerHeight = self.world:getRect(self.player)
    local overlaps = self.world:queryRect(playerX, playerY, playerWidth, playerHeight)

    self.currentTiles = {}

    for _, tile in ipairs(overlaps) do
        if tile.isPuzzleTile then
            table.insert(self.currentTiles, tile)

            local wasOnTile = false
            for _, previousTile in ipairs(self.previousTiles) do
                if previousTile == tile then
                    wasOnTile = true
                end
            end

            if not wasOnTile then
                self:changeTile(tile)
            end
        end
    end

    self.previousTiles = self.currentTiles
end

function PuzzleGameBase:loadPuzzleTiles()
    self.puzzleTilesImage = love.graphics.newImage("maps/gfx/puzzle2_tiles.png")
    local puzzleTileWidth, puzzleTileHeight = 16, 16

    self.puzzleTile = {
        xTile = love.graphics.newQuad(
            0 * puzzleTileWidth,
            0 * puzzleTileHeight,
            puzzleTileWidth,
            puzzleTileHeight,
            self.puzzleTilesImage:getWidth(),
            self.puzzleTilesImage:getHeight()
        ),
        oTile = love.graphics.newQuad(
            1 * puzzleTileWidth,
            0 * puzzleTileHeight,
            puzzleTileWidth,
            puzzleTileHeight,
            self.puzzleTilesImage:getWidth(),
            self.puzzleTilesImage:getHeight()
        ),
        triangleTile = love.graphics.newQuad(
            2 * puzzleTileWidth,
            0 * puzzleTileHeight,
            puzzleTileWidth,
            puzzleTileHeight,
            self.puzzleTilesImage:getWidth(),
            self.puzzleTilesImage:getHeight()
        ),
        oCorrectTile = love.graphics.newQuad(
            3 * puzzleTileWidth,
            0 * puzzleTileHeight,
            puzzleTileWidth,
            puzzleTileHeight,
            self.puzzleTilesImage:getWidth(),
            self.puzzleTilesImage:getHeight()
        )
    }

    -- Load spirte sheet containing button graphics 
    self.objectsImage = love.graphics.newImage("maps/gfx/objects.png")
    local objectsTileWidth, objectsTileHeight = 16, 16 -- Dimensions of each tiles

    self.buttonState = {
        up = love.graphics.newQuad(
            0 * objectsTileWidth,
            9 * objectsTileHeight,
            objectsTileWidth,
            objectsTileHeight,
            self.objectsImage:getWidth(),
            self.objectsImage:getHeight()
        ),
        down = love.graphics.newQuad(
            1 * objectsTileWidth,
            9 * objectsTileHeight,
            objectsTileWidth,
            objectsTileHeight,
            self.objectsImage:getWidth(),
            self.objectsImage:getHeight()
        )
    }

    self.previousTiles = {}
    self.currentTiles = {}

    self:loadPuzzle()
    self:loadButtons()
end

function PuzzleGameBase:loadPuzzle()
    -- First look for a layer name "PuzzleTiles" of type "objectgroup" in the map
    local layer = self.map.layers["PuzzleTiles"]
    if not layer or layer.type ~= "objectgroup"  then
        return  -- No lever layer was found, don't load anything
    end

    -- Initialize an empty table to hold all lever objects
    self.puzzleTiles = {}

    -- Loop through each object in the levers layer and set up the lever
    for _, object in ipairs(layer.objects) do
        if object.name == "puzzle_tile" then
            local tile = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                state = "xTile", -- Inital tile state
                isPuzzleTile = true --Flag to identify this is a tile
            }

            -- Add the tile to the collision world for interaction with the player
            self.world:add(tile, tile.x, tile.y, tile.width, tile.height)

            -- Store the tile in the table
            table.insert(self.puzzleTiles, tile)
        end
    end
end

function PuzzleGameBase:loadButtons()
    -- First look for a layer name "Buttons" of type "objectgroup" in the map
    local layer = self.map.layers["Buttons"]
    if not layer or layer.type ~= "objectgroup"  then
        return  -- No Buttons layer was found, don't load anything
    end

    -- Initialize an empty table to hold all lever objects
    self.buttons = {}

    -- Loop through each object in the levers layer and set up the lever
    for _, object in ipairs(layer.objects) do
        if object.name == "puzzle_button" then
            local button = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                state = "up", -- Inital direction the lever is facing
                isButton = true --Flag to identify this is a lever
            }

            -- Add the lever to the collision world for interaction with the player
            self.world:add(button, button.x, button.y, button.width, button.height)

            -- Store the lever in the table
            table.insert(self.buttons, button)
        end
    end
end

function PuzzleGameBase:loadBoulders()
    -- First look for a layer name "Boulders" of type "objectgroup" in the map
    local layer = self.map.layers["Boulders"]
    if not layer or layer.type ~= "objectgroup"  then
        return -- No boulders layer was found, don't load anything
    end

    -- Initialize an empty table to store all boulder objects
    self.exitBoulders = {}

    -- Loop through each object in the Boulders layer and set up the boulder
    for _, object in ipairs(layer.objects) do
        local boulder = {
            x = object.x,
            y = object.y,
            width = object.width,
            height = object.height
        }

        -- Add the boulder to the collision world for interaction
        self.world:add(boulder, boulder.x, boulder.y, boulder.width, boulder.height)

        -- Store the boulder in the table
        table.insert(self.exitBoulders, boulder)
    end
end

function PuzzleGameBase:changeTile(tile)
    if self.won then
        return
    end

    if tile.state == "xTile" then
        tile.state = "oTile"
    else
        tile.state = "triangleTile"
    end
end

function PuzzleGameBase:checkWinCondition()
    if self.won then
        return
    end

    for _, tile in ipairs(self.puzzleTiles) do
        if tile.state ~= "oTile" then
            for _, puzzleTile in ipairs(self.puzzleTiles) do
                puzzleTile.state = "xTile"
            end
            return
        end
    end

    for _, tile in ipairs(self.puzzleTiles) do
        tile.state = "oCorrectTile"
    end

    self:clearExitBoulders()
end

function PuzzleGameBase:clearExitBoulders()
    -- Mark the game as won
    self.won = true

    -- Remove all boulders from the collision world
    for _, boulder in ipairs(self.exitBoulders) do
        if self.world:hasItem(boulder) then
            self.world:remove(boulder)
        end
    end

    -- Hide the decorative boulder tile layer
    local layer = self.map.layers["BoulderDecorations"]
    if layer and layer.type == "tilelayer" then
        layer.visible = false
    end
end