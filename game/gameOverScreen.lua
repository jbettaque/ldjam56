game.gameOverScreen = {}

local font1 = 0
local largefont = 0
local gameOverAlpha = 0
local winnerAlpha = 0
local showWinnerText = false
local fadeSpeed = 0.5
local looseSounds ={}
local winnSounds ={}
local gameoverSoundPlayed = false


function game.gameOverScreen.load(endGame)
    largefont = love.graphics.newFont(50)
    font1 = love.graphics.newFont(30)
    looseSounds = {
        love.audio.newSource("game/SFX/Audio/Game Over/You Lose/You Lose1.mp3", "static"),
        love.audio.newSource("game/SFX/Audio/Game Over/You Lose/You Lose2.mp3", "static"),
        love.audio.newSource("game/SFX/Audio/Game Over/You Lose/You Lose3.mp3", "static"),
        love.audio.newSource("game/SFX/Audio/Game Over/You Lose/You Lose4.mp3", "static")
    }
    winnSounds = {
        love.audio.newSource("game/SFX/Audio/Game Over/You Win/YouWin1.mp3", "static"),
        love.audio.newSource("game/SFX/Audio/Game Over/You Win/YouWin2.mp3", "static"),

    }
    gameOverAlpha = 0
    winnerAlpha = 0
    showWinnerText = false
    gameoverSoundPlayed = false

end

function game.gameOverScreen.update(dt)

    if gameOverAlpha < 1 then
        gameOverAlpha = gameOverAlpha + fadeSpeed * dt
        if gameOverAlpha >= 1 then
            gameOverAlpha = 1
            showWinnerText = true
        end
    elseif showWinnerText and winnerAlpha < 1 then

        winnerAlpha = winnerAlpha + fadeSpeed * dt
        if winnerAlpha >= 1 then
            winnerAlpha = 1
        end
    end
end

function game.gameOverScreen.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setFont(largefont)


    local gameOverText = "Game over!"
    love.graphics.setColor(1, 1, 1, gameOverAlpha) -- Alpha-Wert für Transparenz
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local gameOverWidth = largefont:getWidth(gameOverText)
    love.graphics.print(gameOverText, (windowWidth - gameOverWidth) / 2, windowHeight / 3)


    if showWinnerText then
        love.graphics.setFont(font1)
        local winnerText = "You lose!"
        if game.manager.checkForGameOver() == 1 then
            winnerText = "You Win!"
            if gameoverSoundPlayed == false then
                local randomIndex = math.random(1, #winnSounds)  -- Choose a random index
                winnSounds[randomIndex]:play()  -- Play the selected sound
                gameoverSoundPlayed = true  -- Set flag to avoid replaying
            end
        elseif game.manager.checkForGameOver() == 2 and gameoverSoundPlayed == false then
            local randomIndex = math.random(1, #looseSounds)  -- Choose a random index
            looseSounds[randomIndex]:play()  -- Play the selected sound
            gameoverSoundPlayed = true  -- Set flag to avoid replaying
        end
        love.graphics.setColor(1, 1, 1, winnerAlpha) -- Alpha-Wert für den Winner-Text
        local winnerWidth = font1:getWidth(winnerText)
        love.graphics.print(winnerText, (windowWidth - winnerWidth) / 2, (windowHeight / 2) - font1:getHeight())

    end



    local rectWidth = 100 -- Width for the "Esc" rectangle
    local rectHeight = 60
    local cornerRadius = 10
    local escText = "Esc"
    local menuText = "Main Menu"


    local escTextWidth = font1:getWidth(escText)
    local menuTextWidth = font1:getWidth(menuText)
    local totalWidth = rectWidth + 20 + menuTextWidth -- Total width of both elements, including a gap of 20 pixels

    local startX = (windowWidth - totalWidth) / 2
    local rectY = windowHeight * 0.75 -- Vertical position for both elements


    love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray rectangle
    love.graphics.rectangle("fill", startX, rectY, rectWidth, rectHeight, cornerRadius, cornerRadius)


    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.setFont(font1)
    love.graphics.print(escText, startX + (rectWidth - escTextWidth) / 2, rectY + (rectHeight - font1:getHeight()) / 2)


    local menuX = startX + rectWidth + 20 -- Position of the "Main Menu" text, with a 20px gap
    love.graphics.print(menuText, menuX, rectY + (rectHeight - font1:getHeight()) / 2)
end

