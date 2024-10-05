game = {}

require("game.map")
require("game.creatures")

function love.load()
    print("running on " .. love.system.getOS())
    game.creatures.load()
end

function love.update(dt)
    game.creatures.update(dt)

end

function love.draw()
    game.map.draw()
    game.creatures.draw()
end