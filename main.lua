if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    Object = require "libraries/classic"
    require "entity"
    require "player"

    -- Library for animating the player movement
    anim8 = require "libraries/anim8"
    love.graphics.setDefaultFilter("nearest", "nearest") -- Remove all bluriness when a transformation is made

    -- Library for basic phyics and collision detection
    bump = require "libraries/bump"

    -- Library to render the map made in tiled and initialise the collisions with bump plugin
    sti = require "libraries/sti"
    map = sti("maps/map.lua", { "bump" })
    world = bump.newWorld()
    map:bump_init(world)

    -- Library for a camera
    gamera = require "libraries/gamera"
    mapWidth = map.width * map.tilewidth
    mapHeight = map.height * map.tileheight
    cam = gamera.new(0, 0, mapWidth, mapHeight) -- Sets the boundaries of the camera
    cam:setScale(3) -- Scales the camera to be more zoomed in

    player = Player(113, 100) -- Renders the player at that position
end

function love.update(dt)
    player:update(dt)

    map:update(dt)

    -- Sets the position of the camera on the players centre
    local camX = player.x + player.frameWidth / 2
    local camY = player.y + player.frameHeight / 2
    cam:setPosition(camX, camY)
end

function love.draw()
    cam:draw(function(l, t, w, h)
        -- Draw the map layer by layer only doing tilelayers
        for _, layer in ipairs(map.layers) do
            if layer.type == "tilelayer" and layer.visible then
                map:drawLayer(layer)
            end
        end

        -- Draw the player
        player:draw()
    end)
end

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end