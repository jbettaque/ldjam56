local powerUps = {}
local coins = {}

function powerUps.load()
    coinImage = love.graphics.newImage("game/Sprites/Coin.png")
end

function powerUps.spawnCoin()
    local add_coin_x = love.math.random(1, love.graphics.getWidth())
    local add_coin_y = love.math.random(1, love.graphics.getHeight())
    table.insert(coins, {x = add_coin_x, y = add_coin_y})
end

function powerUps.update(dt)
end

function powerUps.draw()
    for i = 1, #coins do
        love.graphics.draw(coinImage, coins[i].x, coins[i].y)
    end
end

function powerUps.mousepressed(x, y, button)

    if button == 1 then
        for i = #coins, 1, -1 do
            local coin = coins[i]
            if x > coin.x and x < coin.x + coinImage:getWidth() and y > coin.y and y < coin.y + coinImage:getHeight() then
                table.remove(coins, i)
                print("Coin collected!")
            end
        end
    end
end

return powerUps
