CavernPuzzle4 = PuzzleGameBase:extend()

function CavernPuzzle4:new(x, y)
    CavernPuzzle4.super.new(self, "maps/CavePuzzle4.lua")

    -- Create the player at the given coordinates and register them in the collision world
    self.player = Player (x, y, self.world)

    -- Initialize core variables necessary for the game
    self.won = false

    self:loadPuzzleTiles()
    self:loadBoulders()
    self:loadIceBlocks()

    -- Define a callback function triggered when the player touches a portal 
    -- this will switch the map
    self.player.onPortal = function(_, portal)
        self:switchMap(portal)
    end
end

function CavernPuzzle4:loadIceBlocks()
    local layer = self.map.layers["IceBlocks"]
    if not layer or layer.type ~= "objectgroup" then
        return
    end

    self.iceBlocks = {}

    for _, object in ipairs(layer.objects) do
        if object.name == "ice_block" then
            local iceBlock = {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height,
                isIce = true
            }

            self.world:add(iceBlock, iceBlock.x, iceBlock.y, iceBlock.width, iceBlock.height)
            table.insert(self.iceBlocks, iceBlock)
        end
    end
end

function CavernPuzzle4:switchMap(portal)
    -- Switches the current level with a new instance
    -- The player will spawn at the coordinates defined in the portal's properties
    local spawnX, spawnY = portal.spawn_x, portal.spawn_y
    local map = portal.target_map

    if map == "puzzle3" then
        currentLevel = CavernPuzzle3(spawnX, spawnY)
    end
end