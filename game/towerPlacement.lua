game.towerPlacement = {}

game.towerPlacement.towers = {
}

function game.towerPlacement.load ()
    initiateLaserTurrets()
end
function initiateLaserTurrets()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    table.insert(game.towerPlacement.towers,     {
        id = 1,
        x = screenWidth - 100,
        y = screenHeight/2,
        spawnType = "attacker",
        player = 2,
        health = 10000,
        maxHealth = 10000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        spawningCooldown = 6,
        currentSpawnCooldown = 0,
        laserTurret = true
    })

    table.insert(game.towerPlacement.towers,     {
        id = 2,
        x = 100,
        y = 300,
        spawnType = "attacker",
        player = 1,
        health = 10000,
        maxHealth = 10000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        spawningCooldown = 6,
        currentSpawnCooldown = 0,
        laserTurret = true
    })
end
game.towerPlacement.towerTypes = {"circle", "rectangle", "image"}
game.powerType = {1, 2, 3}
game.towerPlacement.currentPlacingTower = nil

-- Tower type definitions
towerConfig = {
    circle = {
        health = 1000,
        maxHealth = 1000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        radius = 20,
        cost = 100,
        spawnType = "ranger",
        spawningCooldown = 5,
        draw = function(tower, mode)
            love.graphics.circle(mode, tower.x, tower.y, 20)
        end,
        checkClick = function(x, y, tower)
            local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
            return distance <= 20
        end
    },
    rectangle = {
        health = 1200,
        maxHealth = 1200,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 30,
        cost = 50,
        spawnType = "attacker",
        spawningCooldown = 3,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
        end
    },
    image = {
        health = 800,
        maxHealth = 800,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 40,
        cost = 300,
        spawnType = "bomber",
        spawningCooldown = 9,
        draw = function(tower, mode)

                --love.graphics.draw(tower.image, tower.x, tower.y)
                local x, y = tower.x, tower.y  -- center of the octagon
                local radius = 10  -- distance from center to vertex
                local numSides = 8  -- number of sides for the octagon

                -- calculate the angle between each vertex
                local angle = math.pi / numSides

                -- create a table to store the vertices
                local vertices = {}

                -- calculate the vertices
                for i = 0, numSides - 1 do
                    local vx = x + radius * math.cos(i * angle)
                    local vy = y + radius * math.sin(i * angle)
                    table.insert(vertices, vx)
                    table.insert(vertices, vy)
                end

                -- draw the octagon
                love.graphics.polygon("fill", vertices)
        end,
        checkClick = function(x, y, tower)
            local imageWidth, imageHeight = 40, 40
            return x >= tower.x and x <= tower.x + imageWidth and
                    y >= tower.y and y <= tower.y + imageHeight
        end
    }
}
function game.towerPlacement.changeType(type)
    local config = towerConfig[type]
    local spawnType = config.spawnType
    game.towerPlacement.currentPlacingTower.type = type
    --game.towerPlacement.currentPlacingTower.spawnType = spawnType
    --game.towerPlacement.currentPlacingTower.spawningCooldown = config.spawningCooldown
    --game.towerPlacement.currentPlacingTower.health = config.health
    --game.towerPlacement.currentPlacingTower.maxHealth = config.maxHealth
end

function game.towerPlacement.placeTower(x, y, towerType, player)
    local config = towerConfig[towerType] or towerConfig.circle

    local newTower = {
        id = #game.towerPlacement.towers + 1,
        x = x,
        y = y,
        type = towerType,
        player = player or 1,

    }
    game.towerPlacement.currentPlacingTower = newTower
    return newTower
end
function game.towerPlacement.createTower(x, y, towerType, player)

    local config = towerConfig[towerType] or towerConfig.circle

    local newTower = {
        id = #game.towerPlacement.towers + 1,
        x = x,
        y = y,
        type = towerType,
        spawnType = config.spawnType,
        player = player or 1,
        currentSpawnCooldown = 0,
        spawningCooldown = config.spawningCooldown,
        currentSpawnCooldown = 0,
        health = config.health,
        maxHealth = config.maxHealth,
        powerLv = config.powerLv,
        speedLv = config.speedLv,
        healthLv = 1,
    }
    return newTower
end
function game.towerPlacement.addTower(tower)
    towerX, towerY = x, y
    table.insert(game.towerPlacement.towers, tower)
end

function game.towerPlacement.draw()
    game.towerPlacement.drawTowers()
    game.towerPlacement.drawLaserTurret()
end


function game.towerPlacement.drawTowers()

    for i, tower in ipairs(game.towerPlacement.towers) do
        drawTower(tower, "fill")
        love.graphics.setColor(1, 0, 0) -- Weiß für den Text
        love.graphics.print("Lv: " .. tower.powerLv + tower.speedLv, tower.x + 25, tower.y - 10)

        if tower.currentSpawnCooldown > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", tower.x - 10, tower.y + 20, tower.currentSpawnCooldown / tower.spawningCooldown * 40, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", tower.x - 10, tower.y + 20, 40, 5)
        end

        if tower.health < tower.maxHealth then
            local healthbarColor = tower.health / tower.maxHealth
            love.graphics.setColor(0.5, healthbarColor, 0)
            love.graphics.rectangle("fill", tower.x - 10, tower.y + 25, tower.health / tower.maxHealth * 40, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", tower.x - 10, tower.y + 25, 40, 5)
        end

    end
    if game.towerPlacement.currentPlacingTower then
        drawTower(game.towerPlacement.currentPlacingTower, "line")
    end



end
function drawTower(tower, mode)
    if tower.player == 1 then
        love.graphics.setColor(0, 2, 9)
    else
        love.graphics.setColor(1,0,0)
    end
    if tower.type then
        local config = towerConfig[tower.type]
        config.draw(tower, mode)
    end

end

-- Helper function to check if a click is on a tower
function isClickOnTower(x, y, tower)
    local config = towerConfig[tower.type]
    if tower.type == "circle" then
        local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
        return distance <= 20  -- Assuming radius is 20
    elseif tower.type == "rectangle" then
        return x >= tower.x - 10 and x <= tower.x + 30 and
                y >= tower.y - 10 and y <= tower.y + 20
    elseif tower.type == "image" then
        -- Assuming image dimensions, adjust as needed
        local imageWidth, imageHeight = 40, 40
        return x >= tower.x and x <= tower.x + imageWidth and
                y >= tower.y and y <= tower.y + imageHeight
    end
    return false
end

function game.towerPlacement.update(dt)
    for i, v in ipairs(game.towerPlacement.towers) do
        game.towerPlacement.handleLaserTurret(v, dt)
        if v.currentSpawnCooldown > 0 then
            v.currentSpawnCooldown = v.currentSpawnCooldown - (dt * v.speedLv)
            if v.currentSpawnCooldown < 0 then
                v.currentSpawnCooldown = 0
            end
        end
    end


end

function game.towerPlacement.placeTowerForAi(x, y, towerType, player)
    --local config = towerConfig[towerType] or towerConfig.circle

    --local newTower = {
    --    id = #game.towerPlacement.towers + 1,
    --    x = x,
    --    y = y,
    --    type = towerType,
    --    spawnType = config.spawnType,
    --    player = player or 1,
    --    currentSpawnCooldown = 0,
    --    spawningCooldown = config.spawningCooldown,
    --    currentSpawnCooldown = 0,
    --    health = config.health,
    --    powerLv = config.powerLv,
    --    speedLv = config.speedLv,
    --    healthLv = 1,
    --}
    local newTower = game.towerPlacement.createTower(x, y, towerType, player)
    --game.towerPlacement.currentPlacingTower = newTower
    --game.towerPlacement.changeType(towerType)
    game.towerPlacement.addTower(newTower)
end

function game.towerPlacement.handleLaserTurret(tower, dt)
    if not getCreatureStore() then
        print("No creatures")
        return
    end
    if tower.laserTurret then
        for j, creature in ipairs(getCreatureStore()) do
            if creature.player ~= tower.player then
                local distance = math.sqrt((creature.x - tower.x)^2 + (creature.y - tower.y)^2)
                if distance <= 100 then
                    creature.health = creature.health - 1
                    if creature.health <= 0 then
                        table.remove(getCreatureStore(), j)
                        if creature.player == 1 then
                            game.manager.player2.money = game.manager.player2.money + 5
                        else
                            game.manager.player1.money = game.manager.player1.money + 5
                        end
                    end
                end
            end
        end
    end
end

function game.towerPlacement.drawLaserTurret()
    for i, tower in ipairs(game.towerPlacement.towers) do
        if tower.laserTurret then
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("line", tower.x, tower.y, 100)
        end
    end
end