CavernPuzzle2and3 = PuzzleGameBase:extend()

function CavernPuzzle2and3:new(x, y, map)
    self.selectedMap = map

    -- Initialize the base Puzzle Game with the chosen map file
    if self.selectedMap == "puzzle2" then
        CavernPuzzle2and3.super.new(self, "maps/CavePuzzle2.lua")
    elseif self.selectedMap == "puzzle3" then
        CavernPuzzle2and3.super.new(self, "maps/CavePuzzle3.lua")
    end

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player (x, y, self.world)

    -- Initialize the game state variable to track if the puzzle is solved
    self.won = false

    -- Load puzzle tile data and graphics
    self:loadPuzzleTiles()

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function (_, portal)
        self:switchMap(portal)
    end
end

function CavernPuzzle2and3:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    -- Change the current level based of the target map
    if map == "puzzle1" then
        currentLevel = CavernPuzzle1(spawnX, spawnY)
    elseif map == "puzzle2" then
        currentLevel = CavernPuzzle2and3(spawnX, spawnY, map)
    elseif map == "puzzle3" then
        currentLevel = CavernPuzzle2and3(spawnX, spawnY, map)
    elseif map == "puzzle4" then
        currentLevel = CavernPuzzle4(spawnX, spawnY)
    end
end