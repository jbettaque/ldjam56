
local powerUps = {}
local coins = {}

local coinSpawnTimer = 0
local coinSpawnInterval = 5
local coinLifetime = 3

function powerUps.load()
    coinImage = love.graphics.newImage("game/Sprites/Coin.png")
end

function powerUps.spawnCoin()
    local add_coin_x = love.math.random(1, love.graphics.getWidth())
    local add_coin_y = love.math.random(1, love.graphics.getHeight())
    print("Coin spawned at X:" .. add_coin_x .. "  Y:" .. add_coin_y)
    local coin = {
        x = add_coin_x,
        y = add_coin_y,
        lifetime = coinLifetime
    }
    table.insert(coins, coin)
end

function powerUps.update(dt)
    coinSpawnTimer = coinSpawnTimer + dt
    if coinSpawnTimer >= coinSpawnInterval then
        powerUps.spawnCoin()
        coinSpawnTimer = 0
    end


    for i = #coins, 1, -1 do
        coins[i].lifetime = coins[i].lifetime - dt
        if coins[i].lifetime <= 0 then
            table.remove(coins, i)
        end
    end
end

function powerUps.draw()
love.graphics.setColor(1,1,1)
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
                game.manager.addMoney(100, 1)
            end
        end
    end
end

return powerUps
