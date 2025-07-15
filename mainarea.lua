MainArea = MapBase:extend()

function MainArea:new()
    MainArea.super.new(self, "maps/map.lua")
    self.player = Player (113, 100, self.world)
end

function MainArea:update(dt)
    MainArea.super.update(self, dt)
    self.player:update(dt)

    local camX = self.player.x + self.player.frameWidth / 2
    local camY = self.player.y + self.player.frameHeight / 2
    self.cam:setPosition(camX, camY)
end

function MainArea:draw()
    self.cam:draw(function(l, t, w, h)
        self:drawBefore()
        self.player:draw()

        if showDebug then
            self:drawDebug()
        end
    end)
end