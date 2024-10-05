game = {}

require("game.map")
require("game.creatures")
require("game.tMenu")

function love.load()
    print("running on " .. love.system.getOS())
    game.creatures.load()
end

function love.update(dt)
    game.creatures.update(dt)

    game.tMenu.update(dt)
end

function love.draw()
    game.map.draw()
    game.creatures.draw()
    game.tMenu.draw()
end

function love.mousepressed(x, y, button, isTouch)
    game.tMenu.mousepressed(x, y, button, isTouch)

end
