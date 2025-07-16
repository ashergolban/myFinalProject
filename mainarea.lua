MainArea = MapBase:extend()

function MainArea:new(x, y)
    MainArea.super.new(self, "maps/MainMap.lua")
    self.player = Player (x, y, self.world) --spawn location
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function MainArea:switchMap(portal)
    currentLevel = CavernArea(portal.spawn_x, portal.spawn_y)
end