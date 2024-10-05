game = {}

require("game.map")

function love.load()
    print("running on " .. love.system.getOS())
end

function love.update(dt)

end

function love.draw()
    game.map.draw()
end