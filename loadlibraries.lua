function loadLibraries()
    -- This is to load all libraries necessary for this project
    Object = require "libraries/classic"
    anim8 = require "libraries/anim8"
    bump = require "libraries/bump"
    sti = require "libraries/sti"
    gamera = require "libraries/gamera"
end

return { loadLibraries = loadLibraries }