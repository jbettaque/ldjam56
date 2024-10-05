game.manager = {}
game.manager.player1 = {
    money = 0
}
game.manager.player2 = {
    money = 0
}


function game.manager.load()

end

function game.manager.update(dt)
end

function game.manager.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Money: " .. game.manager.player1.money, 10, 10)
end