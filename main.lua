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

function switchToPause()
    currentState = "pause"
end

function endGame()
    currentState = "menu"
end

screenWidth = 1920
screenHeight = 1080
function love.load()
    print("running on " .. love.system.getOS())

    --love.window.setMode(screenWidth, screenHeight)
    game.map.load()
    game.towerPlacement.load()
    game.manager.load()
    game.creatures.load()

    mainMenu.load(switchToGame)
    game.enemyAi.load()
end

function love.update(dt)
    if currentState == "menu" then
        mainMenu.update(dt)
    elseif currentState =="pause" then
        mainMenu.update(dt)
    elseif currentState == "game" then
        game.map.update(dt)
        game.manager.update(dt)
        game.creatures.update(dt)
        game.towerPlacement.update(dt)
        game.tMenu.update(dt)
        game.enemyAi.update(dt)
    end

end

function love.draw()
    love.graphics.scale(love.graphics.getWidth()/screenWidth + 0.2, love.graphics.getHeight()/screenHeight + 0.2)
    --love.graphics.scale(screenWidth/love.graphics.getWidth(), screenHeight/love.graphics.getHeight())

    if currentState == "menu" then

        mainMenu.draw()
    elseif currentState == "pause" then
        mainMenu.changePlayButtonText("Resume Game")
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
    elseif currentState == "pause" then

        mainMenu.mousepressed(x, y, button, presses)
    elseif currentState == "game" then
        if game.map.editorMode then
            game.map.mousepressed(x, y, button)
        else
            game.tMenu.mousepressed(x, y, button, istouch, presses)
        end


    end
end

 function love.keypressed(key)
     if key == "escape" then
         currentState = "pause"
     end
     if key == "c" then
         game.map.editorMode = not game.map.editorMode
     end
 end