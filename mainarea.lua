MainArea = MapBase:extend()

function MainArea:new(x, y)
    MainArea.super.new(self, "maps/MainMap.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player (x, y, self.world) 

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function MainArea:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    currentLevel = CavernArea(portal.spawn_x, portal.spawn_y)
end