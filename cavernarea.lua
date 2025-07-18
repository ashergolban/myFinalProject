CavernArea = MapBase:extend()

function CavernArea:new(x, y)
    CavernArea.super.new(self, "maps/CaveMap.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)
    
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernArea:switchMap(portal)
    if portal.target_map == "main" then
        currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
    elseif portal.target_map == "death" then
        currentLevel = MainArea(113, 100)
    elseif portal.target_map == "puzzle1" then
        -- Puzzle map but i havent gotten to it yet
    end
end