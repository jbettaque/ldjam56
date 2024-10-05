game.manager = {}
game.manager.player1 = {
    money = 50
}
game.manager.player2 = {
    money = 0
}

function game.manager.addMoney(money)
    game.manager.player1.money = game.manager.player1.money + money
end

function game.manager.subtractMoney(money)
    game.manager.player1.money = game.manager.player1.money - money
end

function game.manager.isEnoughMoney(money)
    return game.manager.player1.money >= money
end

function game.manager.load()

end

function game.manager.update(dt)
end

function game.manager.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Money: " .. game.manager.player1.money, 10, 10)
end