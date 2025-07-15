-- Configuration for launching LOVE2D
function love.conf(t)
    t.window.title = "My Game"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = false
    t.window.vsync = 1
    t.window.fullscreen = false
    t.window.msaa = 0
end