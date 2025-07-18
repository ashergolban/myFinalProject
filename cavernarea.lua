CavernArea = MapBase:extend()

function CavernArea:new(x, y)
    CavernArea.super.new(self, "maps/CaveMap.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)
    
    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernArea:switchMap(portal)
    -- Switches the current level with a new instance based of the target map in the portal properties
    -- The player will spawn at the coordinates defined in the portal's properties
    if portal.target_map == "main" then
        currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
    elseif portal.target_map == "death" then
        currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
    elseif portal.target_map == "puzzle1" then
        -- Work in progress for the first puzzle
    end
end