game = {}

require("game.map")
require("game.creatures")
require("game.towerPlacement")
require("game.tMenu")
require("game.manager")
require("game.enemyAi")
require("game.tutorial")
game.powerUps = require("game.powerUps")

local mainMenu = require("game.mainMenu")
local gameOverScreen = require("game.gameOverScreen")

local currentState = "menu"
local tutorialDirty = false

function switchToGame()
    if not tutorialDirty then
        currentState = "tutorial"
        tutorialDirty = true
    else
        currentState = "game"

    end
    music1:stop()
    music2:play()
end

function switchToPause()
    currentState = "pause"
end
function switchToTutorial()
    currentState = "tutorial"
end
function endGame()
    currentState = "gameover"
end
function switchToMainMenu()
    mainMenu.currentMenu = "main"
end
screenWidth = 1080
screenHeight = 720

music1 = love.audio.newSource("game/SFX/Audio/Music/LOOP_1_LD56.mp3", "stream")
music2 = love.audio.newSource("game/SFX/Audio/Music/LOOP_2_LD56.mp3", "stream")

function love.load()
    print("running on " .. love.system.getOS())




    --check if resolution could be set to 1920x1080
    local width, height = love.window.getDesktopDimensions( 1 )
    if width >= 1920 and height >= 1080 then
        screenWidth = 1920
        screenHeight = 1080
        mapsize = 2
    end
    love.window.setMode(screenWidth, screenHeight)

    game.manager.load()
    game.map.load()
    game.towerPlacement.load()
    game.creatures.load()
    game.gameOverScreen.load()
    mainMenu.load(switchToGame)

    game.enemyAi.load()
    game.tMenu.load()

    game.powerUps.load()

    music1:setLooping(true)
    music2:setLooping(true)
    music1:setVolume(0.4)
    music2:setVolume(0.4)

    music1:play()
end

function love.update(dt)
    if currentState == "menu" then
        mainMenu.update(dt)
    elseif currentState =="pause" then
        mainMenu.update(dt)
    elseif currentState == "gameover" then
        game.gameOverScreen.update(dt)
    elseif currentState == "tutorial" then
        game.tutorial.update(dt)
        if not game.tutorial.updatePause then
            game.map.update(dt)
            game.manager.update(dt)
            game.towerPlacement.update(dt)
            game.creatures.update(dt)
            game.tMenu.update(dt)
            game.enemyAi.update(dt)
        end

        game.powerUps.update(dt)
    elseif currentState == "game" then
        game.map.update(dt)
        game.manager.update(dt)
        game.towerPlacement.update(dt)
        game.creatures.update(dt)
        game.tMenu.update(dt)
        game.enemyAi.update(dt)
        game.powerUps.update(dt)
    end

end

function love.draw()
    --love.graphics.scale(love.graphics.getWidth()/screenWidth + 0.2, love.graphics.getHeight()/screenHeight + 0.2)
    --love.graphics.scale(screenWidth/love.graphics.getWidth(), screenHeight/love.graphics.getHeight())

    love.graphics.setDefaultFilter("nearest", "nearest")

    if currentState == "menu" then

        mainMenu.draw()
    elseif currentState == "pause" then
        mainMenu.changePlayButtonText("Resume Game")
        mainMenu.draw()
    elseif currentState == "gameover" then

        game.gameOverScreen.draw()
        mainMenu.changePlayButtonText("Start new Game")
    elseif currentState == "tutorial" then

        game.map.draw()
        game.towerPlacement.draw()
        game.creatures.draw()
        game.tutorial.draw()
        game.tMenu.draw()
        game.enemyAi.draw()
        game.powerUps.draw()
        game.manager.draw()


    elseif currentState == "game" then

        font = love.graphics.newFont(12)
        love.graphics.setFont(font)

        game.map.draw()
        game.towerPlacement.draw()
        game.creatures.draw()
        game.tMenu.draw()
        game.enemyAi.draw()
        game.powerUps.draw()
        game.manager.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if currentState == "menu" then

        mainMenu.mousepressed(x, y, button)
    elseif currentState == "pause" then

        mainMenu.mousepressed(x, y, button, presses)
    elseif currentState == "tutorial" then

        game.tutorial.mousepressed(x, y, button)
        --game.map.mousepressed(x, y, button)
        game.powerUps.mousepressed(x, y, button)
        game.tMenu.mousepressed(x, y, button, istouch, presses)
    elseif currentState == "game" then
        if game.map.editorMode then
            game.map.mousepressed(x, y, button)
        else
            game.tMenu.mousepressed(x, y, button, istouch, presses)
        end
        game.powerUps.mousepressed(x, y, button)


    end
end

 function love.keypressed(key)
     game.tutorial.keypressed(key)
     game.tMenu.keypressed(key)
     if currentState =="gameover" then
         currentState= "menu"
         resetGame()

     elseif key == "escape" then
         currentState = "pause"
     end
     if key == "c" then
         game.map.editorMode = not game.map.editorMode
     end
 end

function resetGame()

    print("reset game")
    local font
    font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    game.towerPlacement.towers = {}

    game.creatures.resetCreatureStore()
    game.map.load()
    game.towerPlacement.load()

    game.creatures.load()
    game.manager.load()
    game.gameOverScreen.load()
    game.enemyAi.load()
    game.powerUps.load()
    love.update(dt)
end
