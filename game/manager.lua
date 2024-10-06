game.manager = {}
game.manager.player1 = {
    money = 300
}
game.manager.player2 = {
    money = 200
}

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

end

function game.manager.update(dt)

end

function game.manager.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Money: " .. game.manager.player1.money, 10, 10)
end