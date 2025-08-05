PuzzleGameBase = MapBase:extend()

function PuzzleGameBase:drawBefore()
    PuzzleGameBase.super.drawBefore(self)

    -- Draw each tile with the correct graphic based on its state
    for _, tile in ipairs(self.puzzleTiles) do
        local loadPuzzleTile = self.puzzleTile[tile.state]
        love.graphics.draw(self.puzzleTilesImage, loadPuzzleTile, tile.x, tile.y)
    end
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
    self:loadPuzzle()
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
    if tile.state == "xTile" then
        tile.state = "oTile"
    else
        tile.state = "triangleTile"
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