PuzzleGameBase = MapBase:extend()

function PuzzleGameBase:update(dt)
    PuzzleGameBase.super.update(self, dt)

   -- Handle puzzle tile state changes
    self:updateTileState()

    -- Handle button press logic and win condition checks
    self:updateButtons()
end

function PuzzleGameBase:drawTileSet(image, quadSet, tiles, offsetX, offsetY)
    -- Draw each image with the correct graphic based on its state
    for _, tile in ipairs(tiles) do
        local quad = quadSet[tile.state]
        love.graphics.draw(image, quad, tile.x + (offsetX or 0), tile.y + (offsetY or 0))
    end
end

function PuzzleGameBase:drawBefore()
    PuzzleGameBase.super.drawBefore(self)

    -- Draw each tile with the correct graphic based on its state
    self:drawTileSet(self.puzzleTilesImage, self.puzzleTile, self.puzzleTiles)

    -- Draw each button with the correct graphic based on its state
    self:drawTileSet(self.objectsImage, self.buttonState, self.buttons, 1, 1)
end

function PuzzleGameBase:getPlayerOverlaps()
    -- Return all collision objects the player is currently overlapping
    local playerX, playerY, playerWidth, playerHeight = self.world:getRect(self.player)
    return self.world:queryRect(playerX, playerY, playerWidth, playerHeight)
end

function PuzzleGameBase:updateTileState()
    -- If puzzleTiles is not defined, don't proceed
    if not self.puzzleTiles then
        return
    end

    -- Get all objects currently overlapping the player
    local overlaps = self:getPlayerOverlaps()

    -- Intialize an empty table to track tiles the player is currently standing on
    self.currentTiles = {}

    -- Iterate over overlapping objects and process only puzzle tiles
    -- Change the tile's state only when the player steps onto it for the first time
    for _, tile in ipairs(overlaps) do
        if tile.isPuzzleTile then
            table.insert(self.currentTiles, tile)

            local wasOnTile = false
            -- Check if the player was already on this tile in the previous update
            for _, previousTile in ipairs(self.previousTiles) do
                if previousTile == tile then
                    wasOnTile = true
                    break
                end
            end

            -- If the player just stepped onto this tile, change its state
            if not wasOnTile then
                self:changeTile(tile)
            end
        end
    end

    -- Update previousTiles for the next frame
    self.previousTiles = self.currentTiles
end

function PuzzleGameBase:updateButtons()
    -- If buttons wasn't defined, dont proceed
    if not self.buttons then
        return
    end

    -- Get all objects currently overlapping the player
    local overlaps = self:getPlayerOverlaps()

    -- Check each button to see if the player is pressing it
    for _, button in ipairs(self.buttons) do
        local isPressed = false

        -- Determine if player overlaps with the current button
        for _, object in ipairs(overlaps) do
            if object == button then
                isPressed = true
                break
            end
        end

        if isPressed then
            -- If button was not previously down or pressed, check win conditions
            if button.state ~= "down" then
                self:checkWinCondition()
            end
            button.state = "down"
        else
            -- Button is not pressed
            button.state = "up"
        end
    end
end

function PuzzleGameBase:createQuad(tileX, tileY, tileWidth, tileHeight, image)
    -- Creates and returns a Quad from a tile's position and size within the given image
    return love.graphics.newQuad(
            tileX * tileWidth,
            tileY * tileHeight,
            tileWidth,
            tileHeight,
            image:getWidth(),
            image:getHeight()
            )
end

function PuzzleGameBase:loadPuzzleTiles()
    -- Load the sprite sheet containing puzzle tiles graphics
    self.puzzleTilesImage = love.graphics.newImage("maps/gfx/puzzle2_tiles.png")
    local puzzleTileWidth, puzzleTileHeight = 16, 16 -- Dimensions of each tile

    -- Quads representing the X, O, Triangle, and correct O tile states
    self.puzzleTile = {
        xTile = self:createQuad(0, 0, puzzleTileWidth, puzzleTileHeight, self.puzzleTilesImage),
        oTile = self:createQuad(1, 0, puzzleTileWidth, puzzleTileHeight, self.puzzleTilesImage),
        triangleTile = self:createQuad(2, 0, puzzleTileWidth, puzzleTileHeight, self.puzzleTilesImage),
        oCorrectTile = self:createQuad(3, 0, puzzleTileWidth, puzzleTileHeight, self.puzzleTilesImage)
    }

    -- Load the sprite sheet containing button graphics 
    self.objectsImage = love.graphics.newImage("maps/gfx/objects.png")
    local objectsTileWidth, objectsTileHeight = 16, 16 -- Dimensions of each tiles

    -- Quad representing the in its "up" and "down" button states
    self.buttonState = {
        up = self:createQuad(0, 9, objectsTileWidth, objectsTileHeight, self.objectsImage),
        down = self:createQuad(1, 9, objectsTileWidth, objectsTileHeight, self.objectsImage)
    }

    -- Intialize tables to track the tiles the player is currently on and was previously on
    self.previousTiles = {}
    self.currentTiles = {}

    -- Load the other puzzle related objects
    self:loadPuzzle()
    self:loadButtons()
    self:loadBoulders()
end

function PuzzleGameBase:loadPuzzle()
    -- First look for a layer name "PuzzleTiles" of type "objectgroup" in the map
    local layer = self.map.layers["PuzzleTiles"]
    if not layer or layer.type ~= "objectgroup"  then
        return  -- No PuzzleTiles layer was found, don't load anything
    end

    -- Initialize an empty table to hold all puzzletile objects
    self.puzzleTiles = {}

    -- Loop through each object in the puzzletiles, looking for an object called 
    -- "puzzle_tile" layer and set up the puzzle tile
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

    -- Initialize an empty table to hold all buttons objects
    self.buttons = {}

    -- Loop through each object in the buttons layer, looking for a object called 
    -- "puzzle_button" and set up the button
    for _, object in ipairs(layer.objects) do
        if object.name == "puzzle_button" then
            local button = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                state = "up", -- Inital state of the button
                isButton = true --Flag to identify this is a button
            }

            -- Add the button to the collision world for interaction with the player
            self.world:add(button, button.x, button.y, button.width, button.height)

            -- Store the button in the table
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
    -- If the player has already won, do not allow intercation with tiles
    if self.won then
        return
    end

    -- Cycle the tile's state between:
    -- 1) x Tile
    -- 2) O Tile
    -- 3) Triangle tile
    if tile.state == "xTile" then
        tile.state = "oTile"
    else
        tile.state = "triangleTile"
    end
end

function PuzzleGameBase:checkWinCondition()
    -- If the player has won, skip win condition checks
    if self.won then
        return
    end

    -- Check if all puzzle tiles are in the "O tile" state
    -- If even one tile is not, reset all tiles back to the X tile state
    local allCorrectTileState = true
    for _, tile in ipairs(self.puzzleTiles) do
        if tile.state ~= "oTile" then
            allCorrectTileState = false
            break
        end
    end

    if allCorrectTileState then
        -- Win condiitons met:
        -- - Change all tiles to the "O correct" state
        -- - Clear the exit boulders
        for _, tile in ipairs(self.puzzleTiles) do
            tile.state = "oCorrectTile"
        end

        self:clearExitBoulders()
    else
        -- Reset all tiles to the X tile state
        for _, tile in ipairs(self.puzzleTiles) do
            tile.state = "xTile"
        end
    end
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