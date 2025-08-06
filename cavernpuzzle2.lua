CavernPuzzle2 = PuzzleGameBase:extend()

function CavernPuzzle2:new(x, y)
    CavernPuzzle2.super.new(self, "maps/CavePuzzle2.lua")

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

function CavernPuzzle2:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    if portal.target_map == "puzzle1" then
        currentLevel = CavernPuzzle1(portal.spawn_x, portal.spawn_y)
    end
end