game.enemyAi = {}

function game.enemyAi.load()

    print("enemyAi loaded")


end

function game.enemyAi.update(dt)
    if game.manager.isEnoughMoney(80, 2) then

        game.manager.player2.money = game.manager.player2.money - 80
        -- randomx and randomy only on right side of screen (1/6th)
        local randomx = math.random(love.graphics.getWidth() - love.graphics.getWidth() / 6, love.graphics.getWidth())
        local randomy = math.random(0, love.graphics.getHeight())
        game.towerPlacement.placeTowerForAi(randomx, randomy, "infantry", 2)
        print("enemyAi bought a tower at " .. randomx .. " " .. randomy)
    end

end

function game.enemyAi.draw()

end