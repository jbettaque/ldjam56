
game.tutorial = {}

currentTutorial = 1



game.tutorial.updatePause = true
game.tutorial.clickPause = false
local hasUpgradableTower = false
local tutorialOver = false
tutorialConfig = {
    {
        draw = function()
            drawPlayAreas()

            --love.graphics.print(tutorialText[currentTutorial], screenWidth/2 - font:getWidth(tutorialText[currentTutorial])/2, screenHeight/6)
            drawText("Welcome to the game! \nLeft click in the highlighted Blue area to Place a tower to spawn creatures.\n\nMines generate mine and others spawn creatures")
            drawText("Red area is enemies area, where enemy places tower", screenWidth/1.5 , screenHeight/1.3)
        end,
        update = function(dt)

            if #game.towerPlacement.towers > 2 then
                increaseTutorial()
            end
        end,
        click = function(x, y)

        end,
        nextFunction = function()
            game.tutorial.updatePause = false
        end
    },
    {
        draw = function()
            love.graphics.setColor(1, 1, 0)
            --love.graphics.print(tutorialText[currentTutorial], screenWidth/2 - font:getWidth(tutorialText[currentTutorial])/2, screenHeight/6)
            drawText("Creatures will spawn from the towers and will attack enemies\n And enemy will also place towers to attack\n\nClick anywhere to continue")
        end,
        update = function(self, dt)

        end,
        click = function(self, x, y)
            increaseTutorial()
        end,
        keypressed = function(key)
            increaseTutorial()
        end,
        nextFunction = function()
            game.tutorial.updatePause = true
            game.manager.player1.money = 690
        end
    },
    {

        draw = function()

            if not hasUpgradableTower then
                drawText("Place another tower that's not mine")
            end


        end,
        update = function(dt)
            if game.manager.player1.money < 300 then
                game.manager.player1.money = 500
            end
            if not hasUpgradableTower then
                for i, v in ipairs(game.towerPlacement.towers) do
                    for i, type in ipairs(game.towerPlacement.towerTypes) do
                        if v.player == 1 then
                            if type ~= "mine"  and type == v.type then
                                increaseTutorial()
                                hasUpgradableTower = true
                            end
                        end

                    end
                end
            end

        end,
    },
    {
        draw = function()
            drawText("Left click on the tower to choose creature type \n Right click to Upgrade a tower\n\n\nUpgrade one tower to continue")
        end,
        update = function(dt)
            for i, v in ipairs(game.towerPlacement.towers) do
                if (v.powerLv + v.speedLv + v.healthLv) > 3 then
                    increaseTutorial()
                end
            end
        end
    },
    {
        draw = function()
            love.graphics.setColor(1, 1, 0)
            --love.graphics.print(tutorialText[currentTutorial], screenWidth/2 - font:getWidth(tutorialText[currentTutorial])/2, screenHeight/6)
            drawText("You might have noticed small coins and \nother good things Appear randomly On the map\nClick them to get coins or small powerups")
            drawText("There are 3 lanes that creatures can take and \nyou cant go through lane walls", nill , screenHeight/2)
            drawText("Click anywhere continue rest of the game\nI'll give you some money to Dominate this round :\")" , nill , screenHeight/1.4)
        end,
        update = function(self, dt)

        end,
        click = function(self, x, y)
            increaseTutorial()
        end,
        keypressed = function(key)
            increaseTutorial()
        end,
        nextFunction = function()
            game.tutorial.updatePause = false
            game.manager.player1.money = 6900
            tutorialOver = true
        end
    },
}

function increaseTutorial(callback)
    if tutorialOver then
        return
    end
    if callback then
        callback()
    end
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].nextFunction then
            tutorialConfig[currentTutorial].nextFunction()
        end
    end
    currentTutorial = currentTutorial + 1
end
function drawText(text, x, y, fontSize)
    love.graphics.setColor(1, 1, 0)
    local newFontS = fontSize or 20
    local font = love.graphics.newFont(newFontS)
    love.graphics.setFont(font)
    local newX = screenWidth/2 - font:getWidth(text)/2
    if x then
        newX = (x - font:getWidth(text)/2)
    end
    love.graphics.printf(
            text,
             newX,
            y or screenHeight/6,
            font:getWidth(text),
            "center"
    )
end


function game.tutorial.update (dt)
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].update then
            tutorialConfig[currentTutorial].update(dt)
        end
    else

    end

end

function game.tutorial.draw ()

    --draw text pretty big and center
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].draw then
            tutorialConfig[currentTutorial].draw()
        end
    end
    if not tutorialOver then
        local font = love.graphics.newFont(14)
        drawText("Press space bar to go to next step quickly :(", screenWidth - font:getWidth("Press space bar to go to next step quickly :(")/2, 0, 14)
    end






end

function game.tutorial.keypressed(key)
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].keypressed then
            tutorialConfig[currentTutorial].keypressed(key)
        end

    end
    if key == "space" then
        if not tutorialOver then
            increaseTutorial()
        end

    end
end

function game.tutorial.mousepressed(x, y, button)
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].click then
            tutorialConfig[currentTutorial].click(x, y)
        end
    end

    --if button == 1 then
    --    currentTutorial = currentTutorial + 1
    --    if currentTutorial > #tutorialText then
    --        currentTutorial = 1
    --    end
    --end
end

