game.tutorial = {}

currentTutorial = 1

game.tutorial.updatePause = true
game.tutorial.clickPause = false
local hasUpgradableTower = false
local tutorialOver = false

-- Enhanced tutorial message display
local function drawTutorialPanel(text, subText, hint)
    -- Draw semi-transparent background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    local panelHeight = 180
    love.graphics.rectangle("fill", 0, screenHeight/8 - 20, screenWidth, panelHeight)

    -- Draw main text
    love.graphics.setColor(1, 1, 0)
    drawText(text, nil, screenHeight/8)

    -- Draw sub-text if provided
    if subText then
        love.graphics.setColor(0.8, 0.8, 0.8)
        drawText(subText, nil, screenHeight/8 + 40, 18)
    end

    -- Draw hint if provided
    if hint then
        love.graphics.setColor(0.7, 0.7, 1)
        drawText(hint, nil, screenHeight/8 + 120, 16)
    end
end

tutorialConfig = {
    {
        draw = function()
            drawPlayAreas()

            drawTutorialPanel(
                    "Welcome to the Game!",
                    "Left click in the highlighted Blue area to Place a tower to spawn creatures.\nYou can't place towers on top of other towers.",
                    "💡 The center of play area is your main HQ. Mines generate coins and other towers spawn creatures."
            )

            -- Keep original extra text for red area
            love.graphics.setColor(1, 0.8, 0.8)
            drawText("Red area is enemies area, where enemy places tower", screenWidth/1.5, screenHeight/1.3)
        end,
        update = function(dt)
            if #game.towerPlacement.towers > 2 then
                increaseTutorial()
            end
        end,
        click = function(x, y) end,
        nextFunction = function()
            game.tutorial.updatePause = false
        end
    },
    {
        draw = function()
            drawTutorialPanel(
                    "Understanding Combat",
                    "Creatures will spawn from your towers and attack enemies.\nEnemy will also place towers to attack you!",
                    "💡 Click anywhere to continue"
            )
        end,
        update = function(self, dt) end,
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
                drawTutorialPanel(
                        "Building Your Army",
                        "Place another tower that's not a mine",
                        "💡 Different tower types spawn different creatures"
                )
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
                            if type ~= "mine" and type == v.type then
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
            drawTutorialPanel(
                    "Tower Management",
                    "Left click on the tower to choose creature type\nRight click to Upgrade a tower",
                    "💡 Upgrade one tower to continue"
            )
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
            drawTutorialPanel(
                    "Final Tips",
                    "Collect coins and power-ups that appear randomly on the map!\nThere are 3 lanes that creatures can take and you can't cross lane walls.",
                    "💡 Click anywhere to start playing - I'll give you some money to dominate this round! :)"
            )
        end,
        update = function(self, dt) end,
        click = function(self, x, y)
            increaseTutorial()
        end,
        keypressed = function(key)
            increaseTutorial()
        end,
        nextFunction = function()
            game.tutorial.updatePause = false
            game.manager.player1.money = 1000
            tutorialOver = true
        end
    },
}

-- Keep your original helper functions
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

-- Keep your original main functions
function game.tutorial.update(dt)
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].update then
            tutorialConfig[currentTutorial].update(dt)
        end
    end
end

function game.tutorial.draw()
    if tutorialConfig[currentTutorial] then
        if tutorialConfig[currentTutorial].draw then
            tutorialConfig[currentTutorial].draw()
        end
    end

    if not tutorialOver then
        local font = love.graphics.newFont(14)
        love.graphics.setColor(1, 0.7, 1)
        drawText("Press space bar to skip tutorial step :)", screenWidth - font:getWidth("Press space bar to skip tutorial step :)  ")/2, 10, 14)
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
end

return game.tutorial