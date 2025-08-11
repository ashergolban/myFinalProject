CavernPuzzle4 = PuzzleGameBase:extend()

function CavernPuzzle4:new(x, y)
    CavernPuzzle4.super.new(self, "maps/CavePuzzle4.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player (x, y, self.world)

    -- Initialize the game state variable to track if the puzzle is solved
    self.won = false

    -- Load puzzle tile data and graphics
    self:loadPuzzleTiles()
    self:loadIceBlocks()
    self:loadFires()

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernPuzzle4:update(dt)
    CavernPuzzle4.super.update(self, dt)

    -- Handle fire related logic
    self:fireFunctionality()
end

function CavernPuzzle4:fireFunctionality()
    -- If fires is not defined, don't proceed
    if not self.fires then
        return
    end

    -- Get all objects currently overlapping the player
    local overlaps = self:getPlayerOverlaps()

    -- Check each fire to see if the player is overlapping any fire objects
    for _, fire in ipairs(self.fires) do
        for _, object in ipairs(overlaps) do
            if object == fire then
                -- If the player touched a fire, reset the puzzle by reloading the level and reposition the player
                currentLevel = CavernPuzzle4(163, 326)
                return
            end
        end
    end
end

function CavernPuzzle4:loadIceBlocks()
    -- First look for a layer name "IceBlocks" of type "objectgroup" in the map
    local layer = self.map.layers["IceBlocks"]
    if not layer or layer.type ~= "objectgroup" then
        return -- No IceBlocks layer was found, don't load anything
    end

    -- Initialize an empty table to hold all iceblocks objects
    self.iceBlocks = {}

    -- Loop through each object in the iceblocks, looking for an object called 
    -- "ice_block" layer and set up the ice block
    for _, object in ipairs(layer.objects) do
        if object.name == "ice_block" then
            local iceBlock = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                isIce = true -- Flag to identify this is a ice block
            }

            -- Add the ice block to the collision world for interaction with the player
            self.world:add(iceBlock, iceBlock.x, iceBlock.y, iceBlock.width, iceBlock.height)

            -- Sotre the ice blocks in the table
            table.insert(self.iceBlocks, iceBlock)
        end
    end
end

function CavernPuzzle4:loadFires()
    -- First look for a layer name "Fires" of type "objectgroup" in the map
    local layer = self.map.layers["Fires"]
    if not layer or layer.type ~= "objectgroup" then
        return -- No Fires layer was found, don't load anything
    end

    -- Initialize an empty table to hold all fires objects
    self.fires = {}

    -- Loop through each object in the fires, looking for an object called 
    -- "fire" layer and set up the fire
    for _, object in ipairs(layer.objects) do
        if object.name == "fire" then
            local fire = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                isFire = true -- Flag to identify this is a fire
            }

            -- Add the fire to the collision world for interaction with the player
            self.world:add(fire, fire.x, fire.y, fire.width, fire.height)

            -- Store the fire in the table
            table.insert(self.fires, fire)
        end
    end
end

function CavernPuzzle4:clearFires()
    -- Remove all fires from the collision world
    for _, fire in ipairs(self.fires) do
        if self.world:hasItem(fire) then
            self.world:remove(fire)
        end
    end

    -- Hide the decorative fires tile layer
    local layer = self.map.layers["FireDecorations"]
    if layer and layer.type == "tilelayer" then
        layer.visible = false
    end
end

function CavernPuzzle4:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    -- Change the current level based of the target map
    if map == "puzzle3" then
        currentLevel = CavernPuzzle2and3(spawnX, spawnY, map)
    end
end