Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y, "sprites/character.png")
    self.speed = 100
    self.frameWidth = self.width / 4
    self.frameHeight = self.height / 4

    self.grid = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight())

    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid("1-4", 1), 0.2)
    self.animations.left = anim8.newAnimation(self.grid("1-4", 4), 0.2)
    self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.2)
    self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.2)

    self.anim = self.animations.down
end

function Player:update(dt)
    Player.super.update(self, dt)

    local isMoving = false

    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.anim = self.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.anim = self.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.anim = self.animations.up
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.anim = self.animations.down
        isMoving = true
    end

    if isMoving == false then
        self.anim:gotoFrame(1)
    end

    self.anim:update(dt)
end

function Player:draw()
    self.anim:draw(self.image, self.x, self.y, nil, 1.5)
end