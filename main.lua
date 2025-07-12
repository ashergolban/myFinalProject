if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    Object = require "libraries/classic"
    require "entity"
    require "player"

    anim8 = require "libraries/anim8"
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require "libraries/sti"
    map = sti("maps/map.lua")

    player = Player(240, 240)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    for _, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" and layer.visible then
            map:drawLayer(layer)
        end
    end
    player:draw()
end

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end