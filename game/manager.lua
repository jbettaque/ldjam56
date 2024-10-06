game.manager = {}
require("game.towerPlacement")

local trickleCooldown = 0
local fps = love.timer.getFPS()
function game.manager.addMoney(money, player)
    if player == 1 then
        game.manager.player1.money = game.manager.player1.money + money
        return
    end
    game.manager.player2.money = game.manager.player2.money + money
end

function game.manager.subtractMoney(money, player)
    if player == 1 then
        game.manager.player1.money = game.manager.player1.money - money
        return
    end
    game.manager.player2.money = game.manager.player2.money - money
end

function game.manager.isEnoughMoney(money, player)
    if player == 1 then
        return game.manager.player1.money >= money
    end
    return game.manager.player2.money >= money
end

function game.manager.load()
    game.manager.player1 = {
        money = 200,
        trickle = 1
    }
    game.manager.player2 = {
        money = 200,
        trickle = 1
    }
    game.manager.playerWon = 0


end

function game.manager.update(dt)
    game.manager.handleMoneyTrickle(dt)
    if game.manager.playerWon ~= 0 then
        return
    end
    game.manager.playerWon = game.manager.checkForGameOver()

    if game.manager.playerWon ~= 0 then
        endGame()
    end
end

function game.manager.draw()
    love.graphics.print("FPS: " .. fps, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Money: " .. game.manager.player1.money, 10, 10)

    love.graphics.print("Trickle cooldown: " .. trickleCooldown, 10, 30)

    if (game.manager.playerWon == 1) then
        love.graphics.print("Player 1 wins", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    end
end

function game.manager.checkForGameOver()
    local p1Count = 0
    local p2Count = 0
    for i, tower in ipairs(game.towerPlacement.towers) do
        if tower.player == 1 then
            p1Count = p1Count + 1
        else
            p2Count = p2Count + 1
        end
    end

    if p1Count == 0 then
        print("Player 2 wins")
        return 2
    end

    if p2Count == 0 then
        print("Player 1 wins")
        return 1
    end

    return 0
end

function game.manager.handleMoneyTrickle(dt)
    local finalTricklePlayer1 = game.manager.player1.trickle
    local finalTricklePlayer2 = game.manager.player2.trickle

    for i, tower in ipairs(game.towerPlacement.towers) do
        if tower.trickle == nil then
            goto continue
        end
        if tower.player == 1 then
            finalTricklePlayer1 = finalTricklePlayer1 + tower.trickle
        else
            finalTricklePlayer2 = finalTricklePlayer2 + tower.trickle
        end
        ::continue::
    end



    if trickleCooldown == 0 then
        game.manager.player1.money = game.manager.player1.money + finalTricklePlayer1
        game.manager.player2.money = game.manager.player2.money + finalTricklePlayer2

        trickleCooldown = 1
    else
        trickleCooldown = trickleCooldown - dt
        if trickleCooldown < 0 then
            trickleCooldown = 0
        end
    end
end