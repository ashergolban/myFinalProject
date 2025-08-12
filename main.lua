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
    require "cavernpuzzle4"

    -- Game areas
    require "mainarea"
    require "cavernarea"

    showDebug = false
    -- currentLevel = MainArea(113, 100)
    currentLevel = CavernArea(80, 383)
    -- currentLevel = CavernPuzzle1(10, 216)
    -- currentLevel = CavernPuzzle2and3(48, 444, "puzzle2")
    -- currentLevel = CavernPuzzle2and3(12, 165, "puzzle3")
    -- currentLevel = CavernPuzzle4(439, 40)
end

function love.update(dt)
    -- Update the current level with the delta time
    currentLevel:update(dt)
end

function love.draw()
    -- Draw the current level
    currentLevel:draw()
end

function love.keypressed(key)
    -- Toggle debug mode when pressing "v"
    if key == "v" then
        showDebug = not showDebug
    end

    -- Pass keypress event to current level if function exists
    if currentLevel and currentLevel.keypressed then
        currentLevel:keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    -- Pass mouse pressed event to current level if function exists
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