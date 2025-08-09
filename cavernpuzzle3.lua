CavernPuzzle3 = PuzzleGameBase:extend()

function CavernPuzzle3:new(x, y)
    CavernPuzzle3.super.new(self, "maps/CavePuzzle3.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player (x, y, self.world)

    -- Initialize core variables necessary for the game
    self.won = false

    self:loadPuzzleTiles()
    self:loadBoulders()

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernPuzzle3:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    if map == "puzzle2" then
        currentLevel = CavernPuzzle2(spawnX, spawnY)
    elseif map == "puzzle4" then
        currentLevel = CavernPuzzle4(spawnX, spawnY)
    end
end