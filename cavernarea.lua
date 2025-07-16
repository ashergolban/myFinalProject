CavernArea = MapBase:extend()

function CavernArea:new(x, y)
    CavernArea.super.new(self, "maps/CaveMap.lua")
    self.player = Player(x, y, self.world)
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernArea:switchMap(portal)
    currentLevel = MainArea(portal.spawn_x, portal.spawn_y)
end