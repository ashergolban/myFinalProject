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
    self.animations = {
        down = anim8.newAnimation(self.grid("1-4", 1), 0.15),
        left = anim8.newAnimation(self.grid("1-4", 4), 0.15),
        right = anim8.newAnimation(self.grid("1-4", 2), 0.15),
        up = anim8.newAnimation(self.grid("1-4", 3), 0.15)
    }
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
    self.world:add(self,
        self.x + self.collisionBox.xOffset,
        self.y + self.collisionBox.yOffset,
        self.collisionBox.width,
        self.collisionBox.height
    )
end

function Player:update(dt)
    Player.super.update(self, dt)

    -- Check if the player is standing on ice
    self:checkIfOnIce()

    if self.onIce then
        -- Handle sliding movement when on ice
        self:slideOnIce(dt)
        return
    end

    -- Process input, update animation, and apply movment
    local dx, dy, isMoving = self:handleMovementInput(dt)
    self:updateAnimation(isMoving, dt)
    self:applyMovement(dx, dy)
end

function Player:handleMovementInput(dt)
    -- Intialize variables for movment detection and x and y displacement of the character
    local dx, dy = 0, 0
    local isMoving = false

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

    return dx, dy, isMoving
end

function Player:updateAnimation(isMoving, dt)
    -- If the player is idle play the frame corresponding to them standing 
    -- in that direction
    if not isMoving then
        self.anim:gotoFrame(1)
    end

    self.anim:update(dt)
end

local function playerCollisionFilter(item, other)
    -- Define how collisions should be resolved, either pass through or solid objects
    if other.isPortal
        or other.isMinesweeperTile
        or other.isLever
        or other.isPuzzleTile
        or other.isButton
        or other.isIce
        or other.isFire
    then
        return "cross"
    end
    return "slide"
end

function Player:applyMovement(dx, dy)
    -- Calculate the destination based on the displacement of the character
    local goalX = self.x + dx
    local goalY = self.y + dy

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

    self:handleCollisions(cols, len)
end

function Player:handleCollisions(cols, len)
    -- Process any collisions that occurred during movement
    for i = 1, len do
        local col = cols[i].other
        -- If the player collided with a portal and has an onPortal callback call it
        if col.isPortal then
            if self.onPortal then
                self:onPortal(col)
            end
        elseif col.isMinesweeperTile and not col.uncovered and not col.flagged then
            -- If the player collided with a tile from the puzzle and has an onRevealTile callback call it
            if self.onRevealTile then
                self:onRevealTile(col)
            end
        end
    end
end

function Player:checkIfOnIce()
    -- Return all collision objects the player is currently overlapping
    local playerX, playerY, playerWidth, playerHeight = self.world:getRect(self)
    local overlaps = self.world:queryRect(playerX, playerY, playerWidth, playerHeight)

    -- Detect if any of the overlaps are ice blocks
    local foundIce = false
    for _, object in ipairs(overlaps) do
        if object.isIce then
            foundIce = true
            break
        end
    end

    if foundIce then
        -- If first time stepping on ice, set slide direction to last movment
        if not self.onIce then
            self.slideDirection = self.lastDirection
        end
        self.onIce = true
    else
        self.onIce = false
    end
end

function Player:slideOnIce(dt)
    -- Intialize variables for movement direction while sliding
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

    -- Keep animation at first frame while sliding
    self.anim:gotoFrame(1)

    -- Calculate the target position based on speed and direction
    local goalX = self.x + dx * self.speed * dt
    local goalY = self.y + dy * self.speed * dt

    -- Moves the player in the world using bump's collision handling
    -- This return the actual poisition after collisions and a list of collisions
    local actualX, actualY, cols, len = self.world:move(self,
        goalX + self.collisionBox.xOffset,
        goalY + self.collisionBox.yOffset,
        playerCollisionFilter
    )

    -- Update the player's position, based on collision resolution
    self.x = actualX - self.collisionBox.xOffset
    self.y = actualY - self.collisionBox.yOffset

    -- If no longer on ice, stop sliding
    self:checkIfOnIce()
    if not self.onIce then
        self.slideDirection = nil
        return
    end

    -- If a collision occurred, stop sliding
    if len > 0 then
        self.onIce = false
        self.slideDirection = nil
    end
end

function Player:draw()
    -- Draw the character
    self.anim:draw(self.image, self.x, self.y)
end