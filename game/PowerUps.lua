local powerUps = {}
local activePowerUps = {}

local powerUpSpawnTimer = 0
local powerUpSpawnInterval = 10
local powerUpLifetime = 3

local powerUpTypes = {
    coin = {
        image = love.graphics.newImage("game/Sprites/Coin.png"),
        effect = function()
            game.manager.addMoney(100, 1)
            print("Coin collected!")
        end,
        lifetime = powerUpLifetime,
        weight = 70-- % Wahrscheinlichkeit
    },
    noDMG = {
        image = love.graphics.newImage("game/Sprites/noDMG.png"),
        effect = function()
            game.creatures.applyHealthBoostToPlayer(1, 10, 10)
            print("No DMG Power-Up collected!")
        end,
        lifetime = powerUpLifetime,
        weight = 10 -- % Wahrscheinlichkeit
    },
    speedBoost = {
        image = love.graphics.newImage("game/Sprites/SpeedBoost.png"),
        effect = function()
            print("Speed Boost collected!")
            game.creatures.applySpeedBoostToPlayer(1, 10, 5)
        end,
        lifetime = powerUpLifetime,
        weight = 10 -- % Wahrscheinlichkeit
    },
    doubleDMG = {
        image = love.graphics.newImage("game/Sprites/doubleDMG.png"),
        effect = function()
            print("Double DMG collected!")
            game.creatures.applyDoubleDamageToPlayer(1, 2, 10)
        end,
        lifetime = powerUpLifetime,
        weight = 10 --  % Wahrscheinlichkeit
    }
}

function powerUps.load()
end


local function choosePowerUp()
    local totalWeight = 0
    for _, powerUp in pairs(powerUpTypes) do
        totalWeight = totalWeight + powerUp.weight
    end

    local randomWeight = love.math.random(0, totalWeight)
    local cumulativeWeight = 0

    for key, powerUp in pairs(powerUpTypes) do
        cumulativeWeight = cumulativeWeight + powerUp.weight
        if randomWeight <= cumulativeWeight then
            return key
        end
    end
end

function powerUps.spawnPowerUp()
    local chosenType = choosePowerUp()

    local add_x = love.math.random(1, love.graphics.getWidth())
    local add_y = love.math.random(1, love.graphics.getHeight())

    print("PowerUp: " .. chosenType .. " Spawned at: X:" .. add_x .. " Y:" .. add_y)

    local powerUp = {
        type = chosenType,
        x = add_x,
        y = add_y,
        lifetime = powerUpTypes[chosenType].lifetime
    }
    table.insert(activePowerUps, powerUp)
end

function powerUps.update(dt)
    powerUpSpawnTimer = powerUpSpawnTimer + dt
    if powerUpSpawnTimer >= powerUpSpawnInterval then
        powerUps.spawnPowerUp()
        powerUpSpawnTimer = 0
    end

    for i = #activePowerUps, 1, -1 do
        activePowerUps[i].lifetime = activePowerUps[i].lifetime - dt
        if activePowerUps[i].lifetime <= 0 then
            table.remove(activePowerUps, i)
        end
    end
end

function powerUps.draw()
    love.graphics.setColor(1, 1, 1)
    for i = 1, #activePowerUps do
        local powerUp = activePowerUps[i]
        love.graphics.draw(powerUpTypes[powerUp.type].image, powerUp.x, powerUp.y)
    end
end

function powerUps.mousepressed(x, y, button)
    if button == 1 then
        for i = #activePowerUps, 1, -1 do
            local powerUp = activePowerUps[i]
            if x > powerUp.x and x < powerUp.x + powerUpTypes[powerUp.type].image:getWidth() and
                    y > powerUp.y and y < powerUp.y + powerUpTypes[powerUp.type].image:getHeight() then
                powerUpTypes[powerUp.type].effect()
                table.remove(activePowerUps, i)
            end
        end
    end
end

return powerUps
