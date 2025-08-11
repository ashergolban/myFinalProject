if arg[2] == "debug" then
    require("lldebugger").start()
end

local fileloader = require "loadlibraries"

function love.load()
    fileloader.loadLibraries()

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Base classes
    require "entity"
    require "player"
    require "mapbase"
    require "puzzlegamebase"

    -- Puzzle maps
    require "cavernpuzzle1"
    require "cavernpuzzle2and3"
    require "cavernpuzzle3"
    require "cavernpuzzle4"

    -- Game areas
    require "mainarea"
    require "cavernarea"

    showDebug = false
    -- currentLevel = MainArea(113, 100)
    -- currentLevel = CavernPuzzle2and3(48, 444, "puzzle2")
    -- currentLevel = CavernPuzzle2and3(12, 165, "puzzle3")
    currentLevel = CavernPuzzle4(439, 40)
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

    if currentLevel and currentLevel.keypressed then
        currentLevel:keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if currentLevel and currentLevel.mousePressed then
        currentLevel:mousePressed(x, y, button)
    end
end

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end