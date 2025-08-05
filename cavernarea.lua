CavernArea = MapBase:extend()

function CavernArea:new(x, y)
    CavernArea.super.new(self, "maps/CaveMap.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player(x, y, self.world)

    -- Function to load Lever objects from the map and add them to the world
    self:loadLevers()

    -- Load spirte sheet containing lever graphics 
    self.objectsImage = love.graphics.newImage("maps/gfx/objects.png")
    local objectsTileWidth, objectsTileHeight = 16, 16 -- Dimensions of each tiles

    -- Quads representing the left and right lever states
    self.leverDirection = {
        left = love.graphics.newQuad(
            2 * objectsTileWidth,
            9 * objectsTileHeight,
            objectsTileWidth,
            objectsTileHeight,
            self.objectsImage:getWidth(),
            self.objectsImage:getHeight()
        ),
        right = love.graphics.newQuad(
            3 * objectsTileWidth,
            9 * objectsTileHeight,
            objectsTileWidth,
            objectsTileHeight,
            self.objectsImage:getWidth(),
            self.objectsImage:getHeight()
        )
    }

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernArea:loadLevers()
    -- First look for a layer name "Levers" of type "objectgroup" in the map
    local layer = self.map.layers["Levers"]
    if not layer or layer.type ~= "objectgroup"  then
        return  -- No lever layer was found, don't load anything
    end

    -- Initialize an empty table to hold all lever objects
    self.levers = {}

    -- Loop through each object in the levers layer and set up the lever
    for _, object in ipairs(layer.objects) do
        if object.name == "difficulty_lever" then
            local lever = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                state = "left", -- Inital direction the lever is facing
                isLever = true --Flag to identify this is a lever
            }

            -- Add the lever to the collision world for interaction with the player
            self.world:add(lever, lever.x, lever.y, lever.width, lever.height)

            -- Store the lever in the table
            table.insert(self.levers, lever)
        end
    end
end

function CavernArea:drawBefore()
    CavernArea.super.drawBefore(self)

    -- Draw each lever with the correct graphic based on its state
    for _, lever in ipairs(self.levers) do
        local loadLeverDirection = self.leverDirection[lever.state]
        love.graphics.draw(self.objectsImage, loadLeverDirection, lever.x + 2, lever.y)
    end
end

function CavernArea:keypressed(key)
    -- Only respond to spacebar presses
    if key ~= "space" then
        return -- If it is any other key, don't load anything
    end

    -- Get the players collision bounds and check for overlaps
    local playerX, playerY, playerWidth, playerHeight = self.world:getRect(self.player)
    local overlaps = self.world:queryRect(playerX, playerY, playerWidth, playerHeight)

    -- If the player overlaps with an object that is a lever
    -- Change the lever state to the opposite direction
    for _, lever in ipairs(overlaps) do
        if lever.isLever and lever.state then
            if lever.state == "left" then
                lever.state = "right"
            else
                lever.state = "left"
            end
        end
    end
end

function CavernArea:switchMap(portal)
    -- Switches the current level with a new instance based of the target map in the portal properties
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    -- Change the current level based of the target map
    if map == "main" or map == "death" then
        currentLevel = MainArea(spawnX, spawnY)
    elseif map == "puzzle1" then
        -- Set the game difficulty to easy as default
        local difficulty = "easy"

        -- Check if any lever state has been switched to the right to change the difficulty to hard
        for _, lever in ipairs(self.levers) do
            if lever.state == "right" then
                difficulty = "hard"
                break
            end
        end

        -- Start the puzzle level with selected difficulty and 3 round lives
        currentLevel = CavernPuzzle1(spawnX, spawnY, difficulty, 3)
    end
end