game = {}


require("game.map")
require("game.tMenu")

function love.load()

end

function love.update(dt)
    game.tMenu.update(dt)
end
function love.draw()
    game.map.draw()
    game.tMenu.draw()
end

function love.mousepressed(x, y, button, isTouch)
    game.tMenu.mousepressed(x, y, button, isTouch)

end
