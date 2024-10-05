game = {}

require("game.map")
require("game.towerPlacement")
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

    game.towerPlacement.drawTowers()
    game.tMenu.draw()
end

function love.mousepressed(x, y, button, isTouch)
    game.tMenu.mousepressed(x, y, button, isTouch)

end


function love.mousepressed(x, y, button, istouch, presses)
    game.tMenu.mousepressed(x, y, button, istouch, presses)
    game.towerPlacement.mousepressed(x, y, button, istouch, presses, "rectangle")

end