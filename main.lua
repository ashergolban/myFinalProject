if arg[2] == "debug" then
    require("lldebugger").start()
end

local fileloader = require "loadlibraries"

function love.load()
    fileloader.loadLibraries()

    love.graphics.setDefaultFilter("nearest", "nearest")

    require "entity"
    require "player"
    require "mapbase"
    require "cavernpuzzle1"
    require "cavernarea"
    require "mainarea"

    showDebug = false
    -- currentLevel = MainArea(113, 100)
    currentLevel = CavernPuzzle1(10, 216)
end

function love.update(dt)
    currentLevel:update(dt)
end

function love.draw()
    currentLevel:draw()
end

function love.keypressed(key)
    if key == "v" then
        showDebug = not showDebug
    end
end

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end