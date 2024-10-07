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
        spawnType = "skelleton",
        player = 2,
        health = 3000,
        maxHealth = 3000,
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
        spawnType = "skelleton",
        player = 1,
        health = 3,
        maxHealth = 3000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        spawningCooldown = 6,
        currentSpawnCooldown = 0,
        laserTurret = true
    })
end
game.towerPlacement.towerTypes = {"aoe", "range", "mage", "infantry", "mine"}
game.powerType = {1, 2, 3}
game.towerPlacement.currentPlacingTower = nil

local aoeImage = love.graphics.newImage("game/Sprites/AOE_Building.png")

-- Tower type definitions
towerConfig = {
    aoe = {
        health = 1000,
        maxHealth = 1000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        radius = 20,
        cost = 100,
        spawnType = "kamikaze",
        possibleSpawnTypes = {"kamikaze", "electro", "acid"},
        spawningCooldown = 5,
        draw = function(tower, mode)
            love.graphics.setColor(1, 1, 1)
            -- draw tower in the middle of the tile
            love.graphics.draw(aoeImage, tower.x, tower.y, 0, 0.3, 0.3, 300, 400)
        end,
        checkClick = function(x, y, tower)
            local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
            return distance <= 20
        end
    },
    mage = {
        health = 1000,
        maxHealth = 1000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        radius = 20,
        cost = 100,
        spawnType = "ghost",
        possibleSpawnTypes = {"ghost", "zombie", "toothFairy"},
        spawningCooldown = 5,
        draw = function(tower, mode)
            love.graphics.circle(mode, tower.x, tower.y, 20)
        end,
        checkClick = function(x, y, tower)
            local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
            return distance <= 20
        end
    },
    range = {
        health = 1200,
        maxHealth = 1200,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 30,
        cost = 50,
        spawnType = "egg",
        possibleSpawnTypes = {"egg", "tooth", "flea"},
        spawningCooldown = 3,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
        end
    },
    mine = {
        health = 600,
        maxHealth = 600,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 30,
        spawnType = "none",
        cost = 50,
        trickle = 5,
        spawningCooldown = 3,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
        end
    },
    infantry = {
        health = 800,
        maxHealth = 800,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 40,
        cost = 100,
        spawnType = "skelleton",
        possibleSpawnTypes = {"carl", "dog", "horde", "skelleton"},
        spawningCooldown = 9,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
        end
    }
}
function game.towerPlacement.changeType(type)
    local config = towerConfig[type]
    game.towerPlacement.currentPlacingTower.type = type
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
        trickle = config.trickle,
        possibleSpawnTypes = config.possibleSpawnTypes,
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
        love.graphics.print("Lv: " .. tower.powerLv + tower.speedLv + tower.healthLv, tower.x + 25, tower.y - 10)

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
    local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
    return distance <= 20  -- Assuming radius is 20
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
    local newTower = game.towerPlacement.createTower(x, y, towerType, player)
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
                    creature.health = creature.health - 0.2
                    game.creature.default.damage(nearestEnemy, creature.meleeDamage)
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