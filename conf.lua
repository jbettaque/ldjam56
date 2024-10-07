function love.conf(t)
    -- make randomness actually random by using the current time as seed
    math.randomseed(os.time())

    t.window.title = "LDJAM56"

    -- configure love
    t.version = "11.5"
    t.identity = "LDJAM56"
    t.window.resizable = true
    t.window.fullscreen = false
    t.modules.joystick = false
    t.modules.touch = false
    t.console = false
end
