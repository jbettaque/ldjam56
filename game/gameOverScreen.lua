game.gameOverScreen= {}

local font1 = 0
local largefont = 0

function game.gameOverScreen.load(endGame)
    largefont = love.graphics.newFont(50)
    font1 = love.graphics.newFont(30)
end

function game.gameOverScreen.update()

end
function game.gameOverScreen.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setFont(largefont)

    love.graphics.setColor(1, 1, 1)
    local gameOverText = "Game over!"
    local winnerText = "You loose!"
    if game.manager.checkForGameOver() == 1 then
        winnerText =  "You Win!"
    end
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local gameOverWidth = largefont:getWidth(gameOverText)
    local gameOverHeight = largefont:getHeight(gameOverText)

    love.graphics.print(gameOverText, (windowWidth - gameOverWidth) / 2, (windowHeight - gameOverHeight) / 3)

    love.graphics.setFont(font1)
    local winnerWidth = font1:getWidth(winnerText)
    local winnerHeight = font1:getHeight(winnerText)
    love.graphics.print(winnerText, (windowWidth - winnerWidth) / 2, (windowHeight - winnerHeight) / 4)
    love.graphics.print("press Esc to return to main Menu")

end

