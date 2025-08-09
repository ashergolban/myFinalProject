Player = Entity:extend()

function Player:new(x, y, world)
    -- Intializing variables necessary for the player
    Player.super.new(self, x, y, "sprites/character.png")
    self.speed = 75
    self.frameWidth = self.width / 4
    self.frameHeight = self.height / 4

    -- Creating an animation grid for all frames
    self.grid = anim8.newGrid(self.frameWidth, self.frameHeight, self.width, self.height)

    -- Creating a table for the different frames for the movements of the character
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid("1-4", 1), 0.15)
    self.animations.left = anim8.newAnimation(self.grid("1-4", 4), 0.15)
    self.animations.right = anim8.newAnimation(self.grid("1-4", 2), 0.15)
    self.animations.up = anim8.newAnimation(self.grid("1-4", 3), 0.15)
    self.anim = self.animations.down

    -- Setting up a collison box for the player
    self.collisionBox = {
        xOffset = 2,
        yOffset = self.frameHeight / 2,
        width = self.frameWidth - 5,
        height = (self.frameHeight / 2) - 1
    }

    -- Store a reference to the collision world passed from the map
    self.world = world

    -- Add the player to the collision world with their collision box dimensions
    self.world:add(self, self.x + self.collisionBox.xOffset, 
    self.y + self.collisionBox.yOffset,
    self.collisionBox.width,
    self.collisionBox.height)
end


function Player:update(dt)
    Player.super.update(self, dt)

    self:checkIfOnIce()

    if self.onIce then
        self:slideOnIce(dt)
        return
    end

    -- Intialize variables for movment detection and x and y displacement of the character
    local dx, dy = 0, 0
    local isMoving = false

    if not self.onIce then
        -- Character movement logic
        if love.keyboard.isDown("left") then
            self.lastDirection = "left"
            dx = dx - self.speed * dt
            self.anim = self.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("right") then
            self.lastDirection = "right"
            dx = dx + self.speed * dt
            self.anim = self.animations.right
            isMoving = true
        end

        if love.keyboard.isDown("up") then
            self.lastDirection = "up"
            dy = dy - self.speed * dt
            self.anim = self.animations.up
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            self.lastDirection = "down"
            dy = dy + self.speed * dt
            self.anim = self.animations.down
            isMoving = true
        end
    end

    -- If the player is idle play the frame corresponding to them standing 
    -- in that direction
    if isMoving == false then
        self.anim:gotoFrame(1)
    end

    self.anim:update(dt)

    -- Calculate the destination based on the displacement of the character
    local goalX = self.x + dx
    local goalY = self.y + dy

    -- Defin how collisions should be resolved, either pass through or solid objects
    local function playerCollisionFilter(item, other)
        if other.isPortal
           or other.isMinesweeperTile
           or other.isLever
           or other.isPuzzleTile
           or other.isButton
           or other.isIce
        then
            return "cross"
        end
        return "slide"
    end

    -- Moves the player in the world using bump's collision handling
    -- This return the actual poisition after collisions and a list of collisions
    local actualX, actualY, cols, len = self.world:move(self,
        goalX + self.collisionBox.xOffset,
        goalY + self.collisionBox.yOffset,
        playerCollisionFilter
    )

    -- Update the player's position, accounting for collision box offset
    self.x = actualX - self.collisionBox.xOffset
    self.y = actualY - self.collisionBox.yOffset

    -- Process any collisions that occurred during movement
    for i = 1, len do
        local col = cols[i].other
        -- If the player collided with a portal and has an onPortal callback call it
        if col.isPortal then
            if self.onPortal then
                self:onPortal(col)
            end
        end

        -- If the player collided with a tile from the puzzle and has an onRevealTile callback call it
        if col.isMinesweeperTile and not col.uncovered and not col.flagged then
            if self.onRevealTile then
                self:onRevealTile(col)
            end
        end
    end
end

function Player:checkIfOnIce()
    local PlayerX, PlayerY, PlayerW, PlayerH = self.world:getRect(self)
    local overlaps = self.world:queryRect(PlayerX, PlayerY, PlayerW, PlayerH)

    local foundIce = false
    for _, object in ipairs(overlaps) do
        if object.isIce then
            foundIce = true
            break
        end
    end

    if foundIce then
        if not self.onIce then
            self.slideDirection = self.lastDirection
        end
        self.onIce = true
    else
        self.onIce = false
    end
end

function Player:slideOnIce(dt)
    local dx, dy = 0, 0

    if self.slideDirection == "left" then
        dx = -1
        self.anim = self.animations.left
    elseif self.slideDirection == "right" then
        dx = 1
        self.anim = self.animations.right
    elseif self.slideDirection == "up" then
        dy = -1
        self.anim = self.animations.up
    elseif self.slideDirection == "down" then
        dy = 1
        self.anim = self.animations.down
    end

    self.anim:gotoFrame(1)

    local goalX = self.x + dx * self.speed * dt
    local goalY = self.y + dy * self.speed * dt

        -- Defin how collisions should be resolved, either pass through or solid objects
    local function playerCollisionFilter(item, other)
        if other.isPortal
           or other.isMinesweeperTile
           or other.isLever
           or other.isPuzzleTile
           or other.isButton
           or other.isIce
        then
            return "cross"
        end
        return "slide"
    end

    local actualX, actualY, cols, len = self.world:move(self,
        goalX + self.collisionBox.xOffset,
        goalY + self.collisionBox.yOffset,
        playerCollisionFilter
    )

    self.x = actualX - self.collisionBox.xOffset
    self.y = actualY - self.collisionBox.yOffset

    self:checkIfOnIce()
    if not self.onIce then
        self.slideDirection = nil
        return
    end

    if len > 0 then
        self.onIce = false
        self.slideDirection = nil
    end
end

function Player:draw()
    -- Draw the character
    self.anim:draw(self.image, self.x, self.y)
end