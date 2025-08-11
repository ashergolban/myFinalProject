CavernPuzzle1 = MapBase:extend()

-- Adapted from "Flowers - A tutorial for Lua and LÖVE 11" by berbasoft
-- https://berbasoft.com/simplegametutorials/love/flowers/

function CavernPuzzle1:new(x, y, difficulty, roundLives)
    CavernPuzzle1.super.new(self, "maps/CavePuzzle1.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)

    -- Initialize core variables necessary for the game
    self.firstTileRevealed = false
    self.won = false
    self.gameDifficulty = difficulty
    self.roundLives = roundLives
    self.mapSwitchingDelay = 2.5

    -- Set skull lives for easier difficulty
    if self.gameDifficulty == "easy" then
        self.lives = 3
    end

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function (_, portal)
        self:switchMap(portal)
    end

    -- Load minsweeper functionality and exit boulders
    self:minesweeperFunctionality()
    self:loadBoulders()

    -- Defin a callback function triggered when the player touches a tile
    -- this will reveal the tile
    self.player.onRevealTile = function (_, tile)
        self:revealTile(tile)
    end
end

function CavernPuzzle1:update(dt)
    CavernPuzzle1.super.update(self, dt)

    -- Handle delayed map switching
    if self.switchDelay then
        self.switchDelay = self.switchDelay - dt
        if self.switchDelay <= 0 and self.delayedMapSwitch then
            self.delayedMapSwitch()
            self.switchDelay = nil
            self.delayedMapSwitch = nil
        end
    end

    if self.minesweeperZone then
        -- Convert mouse position to tile coordinates
        local zone = self.minesweeperZone
        local mouseX, mouseY = self.cam:toWorld(love.mouse.getPosition())
        local tileWidth = self.map.tilewidth
        local tileHeight = self.map.tileheight

        -- Calculate which tile is currently selected by the cursor
        self.selectedX = math.floor((mouseX - zone.x) / tileWidth) + 1
        self.selectedY = math.floor((mouseY - zone.y) / tileHeight) + 1

        -- Clamp the selected tile coordinates within the puzzle grid bounds
        local cols, selectedX = self.cols, self.selectedX
        local rows, selectedY = self.rows, self.selectedY
        self.selectedX = math.max(1, math.min(cols, selectedX))
        self.selectedY = math.max(1, math.min(rows, selectedY))
    end
end

function CavernPuzzle1:drawTile(tileName, currentTile)
    -- Draw the given tile based of the tileName at its position
    love.graphics.draw(self.image, self.tiles[tileName], currentTile.x, currentTile.y)
end

function CavernPuzzle1:drawBefore()
    -- Draw only all visible tile layers in the correct order
    CavernPuzzle1.super.drawBefore(self)

    if self.minesweeperZone then
        -- Intiamize variables necessary for the drawing Minesweeper tiles
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

        for _, tile in ipairs(self.minesweeperTiles) do
            if not tile.uncovered then
                -- Set the default tiles as covered
                local tileName = "covered"
                local col, row = tile.col, tile.row

                -- Highlight tile if mouse is hovering over it
                if self.selectedX == col and self.selectedY == row then
                    tileName = "covered_highlighted"
                end

                self:drawTile(tileName, tile)

                -- Overlay flag or question marks if marked
                if tile.flagged then
                    self:drawTile("flag", tile)
                elseif tile.questioned then
                    self:drawTile("question", tile)
                end
            else
                if tile.hasSkull then
                    self:drawTile("skull", tile)
                else
                    self:drawTile("uncovered", tile)
                    -- If the tile is near skuls
                    -- Draw the number corresponding the nearbySkullCount ontop of the uncovered tile
                    if tile.nearbySkullCount and tile.nearbySkullCount > 0 then
                        local numName = numberNames[tile.nearbySkullCount]

                        if numName then
                            self:drawTile(numName, tile)
                        end
                    end
                end
            end
        end
    end
end

function CavernPuzzle1:minesweeperFunctionality()
    -- Load Minesweeper sprite sheet and determine its dimensions
    self.image = love.graphics.newImage("maps/gfx/minesweeper.png")
    local imageWidth = self.image:getWidth()
    local imageHeight = self.image:getHeight()

    -- Define tile names in the order they appear on the spirte sheet
    local tileNames = {
        {'covered', 'covered_highlighted', 'uncovered', 'skull', 'flag','question', 'one'},
        {'two', 'three', 'four', 'five', 'six', 'seven', 'eight'}
    }

    -- Initialize table to store named tile quads
    self.tiles = {}

    -- Determine each frames dimensions
    self.imageFrameWidth = imageWidth / 7
    self.imageFrameHeight = imageHeight / 2

    -- Create each tile as a quad into the table as a Key Value pair with name-based keys
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
    -- Once quads are setup, initialize the Minesweeper area
    self:loadMinesweeperArea()
end

function CavernPuzzle1:loadMinesweeperArea()
    -- First look for a layer name "MinesweeperArea" of type "objectgroup" in the map
    local layer = self.map.layers["MinesweeperArea"]
    if not layer or layer.type ~= "objectgroup" then
        return -- No minesweeperarea layer was found, dont load anything
    end

    -- Initialize an empty table to store the minesweeper tiles
    self.minesweeperTiles = {}

    -- Loop through each object in MinesweeperArea layer with the object name "minesweeper_zone"
    -- Then define the minesweeper zone
    for _, object in ipairs(layer.objects) do
        if object.name == "minesweeper_zone" then
            self.minesweeperZone = {
            x = object.x,
            y = object.y,
            width = object.width,
            height = object.height
            }

            -- Calculate tile grid size from the zone dimensions
            self.cols = math.floor(self.minesweeperZone.width / self.map.tilewidth)
            self.rows = math.floor(self.minesweeperZone.height / self.map.tileheight)
            break
        end
    end

    -- If the minesweeper zone wasn't defined, don't proceed
    if not self.minesweeperZone then
        return
    end

    -- Loop through each object in MinesweeperArea layer with the object name "minesweeper_tile"
    -- Then initialize the minesweeper tile
    for _, object in ipairs(layer.objects) do
        if object.name == "minesweeper_tile" then
            local tile = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                col = math.floor((object.x - self.minesweeperZone.x) / self.map.tilewidth) + 1, -- Column the tile is located at
                row = math.floor((object.y - self.minesweeperZone.y) / self.map.tileheight) + 1, -- Row the tile is located at
                uncovered = false, -- Flag for uncovering the tile
                flagged = false, -- Flag for flagging the tile
                questioned = false, -- Flag for question marking the tile
                isMinesweeperTile = true, -- Flag to identify the tile is a minesweeper tile
                hasSkull = false, -- Flag for skull tile
                nearbySkullCount = 0 -- Count for the amount of nearbySkulls 
            }

            -- Add the tile to the collision world for interaction with the player
            self.world:add(tile, tile.x, tile.y, tile.width, tile.height)

            -- Store the tile in table
            table.insert(self.minesweeperTiles, tile)
        end
    end

    -- Sort all tiles by row and column so that they are in consistent order to be accessed
    table.sort(self.minesweeperTiles, function (a, b)
        if a.row == b.row then
            return a.col < b.col
        else
            return a.row < b.row
        end
    end)

    -- Build the Minesweeper grid
    self:buildTileGrid()
end

function CavernPuzzle1:loadBoulders()
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

function CavernPuzzle1:buildTileGrid()
    -- Initialize an empty 2D table grid 
    self.tileGrid = {}

    -- Loop through all minesweeper tiles and assign them to the grid based on their row and column
    for _, tile in ipairs(self.minesweeperTiles) do
        local col, row = tile.col, tile.row
        self.tileGrid[row] = self.tileGrid[row] or {} -- Create row if it doesn't exist
        self.tileGrid[row][col] = tile -- Assign tile to grid position
    end
end

function CavernPuzzle1:revealTile(tile)
    -- If the player is dead or has won, dont allow interaction with tiles
    if self.dead or self.won then
        return
    end

    -- If the tile is already uncovered or flagged, do nothing
    if tile.uncovered or tile.flagged then
        return
    end

    -- If this is the first tile being revealed, place skulls on the board
    if not self.firstTileRevealed then
        self:placeSkulls(tile)
        self.firstTileRevealed = true
    end

    -- If the tile is a skull load the function reveal Skull tile
    if tile.hasSkull then
        self:revealSkullTile(tile)
        return
    end

    -- Create a table with only the tile that the player interacted 
    -- to start a flood fill from this tile to reveal connected empty tiles
    local stack = { tile }

    while #stack > 0 do
        -- Pop a tile from the stack
        local currentTile = table.remove(stack)
        
        -- Reveal the tile if it's not already uncovered
        if not currentTile.uncovered then
            currentTile.uncovered = true

            -- If there are no nearby skulls and the tile isn't marked with a question,
            -- add all adjacent safe tiles to the stack to reveal them recursively
            if currentTile.nearbySkullCount == 0 and not currentTile.questioned then
                for _, adjacentTile in ipairs(self:getAdjacentTiles(currentTile)) do
                    if adjacentTile
                       and not adjacentTile.uncovered
                       and not adjacentTile.flagged
                       and not adjacentTile.hasSkull
                    then
                        table.insert(stack, adjacentTile)
                    end
                end
            end
        end
    end

    -- Atfer revealing, check if the win conditions has been met
    self:checkWinCondition()
end

function CavernPuzzle1:placeSkulls(startingTile)
    -- Initialize variables for placing the skulls on the board
    local skullCount = 10 -- Number of skulls to place
    local placedSkulls = 0
    local usedSkullPositions = {}

    -- Randomaly place skulls on the board, avoiding the starting tile
    while placedSkulls < skullCount do
        local index = love.math.random(#self.minesweeperTiles)
        local currentTile = self.minesweeperTiles[index]

        -- Only place a skull if it's not the starting tile and hasn't been used
        if not usedSkullPositions[index]
           and not (currentTile.row == startingTile.row and currentTile.col == startingTile.col)
        then
            usedSkullPositions[index] = true
            currentTile.hasSkull = true
            placedSkulls = placedSkulls + 1
        end
    end

    -- For each tile, calculate how many skulls are adjacent to it
    for _, tile in ipairs(self.minesweeperTiles) do
        local surroundingSkullCount = 0

        for _, adjacentTile in ipairs(self:getAdjacentTiles(tile)) do
            if adjacentTile.hasSkull then
                surroundingSkullCount = surroundingSkullCount + 1
            end
        end

        -- Set the number of nearby skulls for the tile
        tile.nearbySkullCount = surroundingSkullCount
    end
end

function CavernPuzzle1:handleGameOverState(roundLives)
    -- If the player has no round lives left, return them to the starting area
    -- Otherwise, reload the current puzzle
    if roundLives <= 0 then
        currentLevel = MainArea(113, 100)
        return
    else
        currentLevel = CavernPuzzle1(10, 216, self.gameDifficulty, self.roundLives)
        return
    end
end

function CavernPuzzle1:revealAllSkullTiles()
    -- Loop through all tiles and reveal those that contain skulls
    for _, tile in ipairs(self.minesweeperTiles) do
        if tile.hasSkull then
            tile.uncovered = true
        end
    end
end

function CavernPuzzle1:triggerSkullGameOver()
    -- Handles the logic for triggering a game over state after the player hits a skull
    self:revealAllSkullTiles()
    self.dead = true  -- Makring the player as dead
    self.roundLives = self.roundLives - 1 -- Reducing round lives
    self.switchDelay = self.mapSwitchingDelay -- Starting the delayed transition to the game over state
    self.delayedMapSwitch = function ()
        self:handleGameOverState(self.roundLives)
    end
end

function CavernPuzzle1:revealSkullTile(skullTile)
    -- Reveal the skull tile
    skullTile.uncovered = true

    -- Apply logic depending on the game difficulty
    if self.gameDifficulty == "easy" then
        -- On easy mode, the player can hit up to 3 skulls before losing
        self.lives = self.lives - 1

        -- If no lives remain, reveal all skulls and transition to game over
        if self.lives <= 0 and self.roundLives > 0 then
            self:triggerSkullGameOver()
            return
        end
    elseif self.gameDifficulty == "hard" then
        -- On hard mode, one skull ends the round immediately
        self:triggerSkullGameOver()
        return
    end
end

function CavernPuzzle1:checkWinCondition()
    -- Check if all win conditions are met:
    -- - All skulls tiles must be flagged or uncovered(*)
    -- - All safe tiles must be uncovered and not flagged
    -- (*) THIS IS AN EXCEPTION. In easy mode, skulls can be uncovered as long as the player hasn't lost all 3 lives
    for _, tile in ipairs(self.minesweeperTiles) do
        if tile.hasSkull then
            if not tile.flagged and not tile.uncovered then
                return -- A skull tile is still hidden and unflagged
            end
        else
            if not tile.uncovered or tile.flagged then
                return -- A safe tile is either still hidden or incorrectly flagged
            end
        end
    end

    -- If win conditions are met and the win hasn't been triggered, do it now
    if not self.won then
        self:clearExitBoulders()
    end
end

function CavernPuzzle1:clearExitBoulders()
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

function CavernPuzzle1:getAdjacentTiles(tile)
    -- Get all valid adjacent tiles in a 3x3 grid around the given tile
    local adjacentTiles = {}

    for dy = -1, 1 do
        for dx = -1, 1 do
            -- Skip the tile itself
            if not (dx == 0 and dy == 0) then
                local adjacentRow = tile.row + dy
                local adjacentCol = tile.col + dx

                -- If the position is valid and exists in the grid, add it to the list
                if self.tileGrid[adjacentRow] and self.tileGrid[adjacentRow][adjacentCol] then
                    table.insert(adjacentTiles, self.tileGrid[adjacentRow][adjacentCol])
                end
            end
        end
    end

    return adjacentTiles
end

function CavernPuzzle1:toggleFlagQuestion(tile)
    -- Cycle through the tile state between:
    -- 1) unmarked
    -- 2) flagged
    -- 3) questioned
    -- 4) unmarked
    if not tile.flagged and not tile.questioned then
        tile.flagged = true
    elseif tile.flagged then
        tile.flagged = false
        tile.questioned = true
    else
        tile.questioned = false
    end
end

function CavernPuzzle1:mousePressed(x, y, button)
    -- Prevent interaction if the player is dead or has won
    if self.dead or self.won then
        return
    end

    -- If right click and a tile is selected
    if button == 2 and self.selectedX and self.selectedY then
        -- FInd the tile under the selected coordinates and toggle its flag/question mark state
        for _, tile in ipairs(self.minesweeperTiles) do
            local  col, row = tile.col, tile.row
            if col == self.selectedX and row == self.selectedY and not tile.uncovered then
                self:toggleFlagQuestion(tile)
                break
            end
        end
    end

    -- After interaction, check if win the conditions has been met
    self:checkWinCondition()
end

function CavernPuzzle1:switchMap(portal)
    -- Switches the current level with a new instance based of the target map in the portal properties
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    if map == "puzzle2" then
        currentLevel = CavernPuzzle2and3(spawnX, spawnY, map)
    end

    -- Only allows switching if the player has won the puzzle
    if not self.won then
        return
    end

    if map == "cavern" then
        currentLevel = CavernArea(spawnX, spawnY)
    end
end