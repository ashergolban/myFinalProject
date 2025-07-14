Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y, "sprites/character.png")
    self.speed = 75
    self.frameWidth = self.width / 4
    self.frameHeight = self.height / 4

    self.grid = anim8.newGrid(self.frameWidth, self.frameHeight, self.width, self.height)

    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid("1-4", 1), 0.15)
    self.animations.left = anim8.newAnimation(self.grid("1-4", 4), 0.15)
    self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.15)
    self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.15)
    self.anim = self.animations.down

    self.collisionBox = {
        xOffset = 0,
        yOffset = self.frameHeight / 2,
        width = self.frameWidth,
        height = self.frameHeight / 2
    }
    world:add(self, self.x + self.collisionBox.xOffset, 
    self.y + self.collisionBox.yOffset, 
    self.collisionBox.width, 
    self.collisionBox.height)
end

function Player:update(dt)
    Player.super.update(self, dt)

    local dx, dy = 0, 0
    local isMoving = false

    if love.keyboard.isDown("left") then
        dx = dx - self.speed * dt
        self.anim = self.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("right") then
        dx = dx + self.speed * dt
        self.anim = self.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        dy = dy - self.speed * dt
        self.anim = self.animations.up
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        dy = dy + self.speed * dt
        self.anim = self.animations.down
        isMoving = true
    end

    if isMoving == false then
        self.anim:gotoFrame(1)
    end

    self.anim:update(dt)

    local goalX = self.x + dx
    local goalY = self.y + dy

    local actualX, actualY, cols, len = world:move(self,
        goalX + self.collisionBox.xOffset,
        goalY + self.collisionBox.yOffset
    )

    player.x = actualX - self.collisionBox.xOffset
    player.y = actualY - self.collisionBox.yOffset
end

function Player:draw()
    self.anim:draw(self.image, self.x, self.y)
end