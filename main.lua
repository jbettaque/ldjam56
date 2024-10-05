game = {}

require("game.map")
require("game.creatures")
require("game.towerPlacement")
require("game.tMenu")
require("game.manager")
require("game.enemyAi")

local mainMenu = require("game.mainMenu")

local currentState = "menu"

function switchToGame()
    currentState = "game"
end

function love.load()
    print("running on " .. love.system.getOS())


    game.manager.load()
    game.creatures.load()

    mainMenu.load(switchToGame)
    game.enemyAi.load()
end

function love.update(dt)
    if currentState == "menu" then
        mainMenu.update(dt)

    elseif currentState == "game" then
        game.manager.update(dt)
        game.creatures.update(dt)
        game.towerPlacement.update(dt)
        game.tMenu.update(dt)
        game.enemyAi.update(dt)
    end

end

function love.draw()
    if currentState == "menu" then

        mainMenu.draw()
    elseif currentState == "game" then

        game.manager.draw()
        game.map.draw()
        game.creatures.draw()
        game.towerPlacement.draw()
        game.tMenu.draw()
        game.enemyAi.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if currentState == "menu" then

        mainMenu.mousepressed(x, y, button)
    elseif currentState == "game" then

        game.tMenu.mousepressed(x, y, button, istouch, presses)
    end
end
