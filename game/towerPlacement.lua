game.towerPlacement = {}

game.towerPlacement.towers = {}
game.towerPlacement.towerTypes = {"circle", "rectangle", "image"}
game.powerType = {1, 2, 3}
game.towerPlacement.currentPlacingTower = nil

-- Tower type definitions
towerConfig = {
    circle = {
        health = 1000,
        powerLv = 1,
        radius = 20,
        spawnType = "ranger",
        spawningCooldown = 1,
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
        powerLv = 1,
        width = 40,
        height = 30,
        spawnType = "attacker",
        spawningCooldown = 1,
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
        powerLv = 1,
        width = 40,
        height = 40,
        spawnType = "bomber",
        spawningCooldown = 4,
        draw = function(tower, mode)
            if tower.image then
                love.graphics.draw(tower.image, tower.x, tower.y)
            end
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
    game.towerPlacement.currentPlacingTower.spawnType = spawnType
    game.towerPlacement.currentPlacingTower.spawningCooldown = config.spawningCooldown
end

function game.towerPlacement.placeTower(x, y, towerType)
    local config = towerConfig[towerType] or towerConfig.circle

    local newTower = {
        id = #game.towerPlacement.towers + 1,
        x = x,
        y = y,
        type = towerType,
        spawnType = config.spawnType,
        player = 1,
        currentSpawnCooldown = 0,
        spawningCooldown = config.spawningCooldown,
        health = config.health,
        powerLv = config.powerLv
    }
    game.towerPlacement.currentPlacingTower = newTower
    return newTower
end

function game.towerPlacement.addTower(tower)
    towerX, towerY = x, y
    table.insert(game.towerPlacement.towers, tower)
end


function game.towerPlacement.drawTowers()

    for i, tower in ipairs(game.towerPlacement.towers) do
        drawTower(tower, "fill")
        love.graphics.setColor(1, 0, 0) -- Weiß für den Text
        love.graphics.print("Lv: " .. tower.powerLv, tower.x + 25, tower.y - 10)
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
    if tower.type == "circle" then
        love.graphics.circle(mode, tower.x, tower.y, 20)

    elseif tower.type == "rectangle" then
        love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
    elseif tower.type == "image" then
        if tower.image then
            love.graphics.draw(tower.image, tower.x, tower.y)

        end
    end

end

-- Helper function to check if a click is on a tower
function isClickOnTower(x, y, tower)
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
        if v.currentSpawnCooldown > 0 then
            v.currentSpawnCooldown = v.currentSpawnCooldown - dt
            if v.currentSpawnCooldown < 0 then
                v.currentSpawnCooldown = 0
            end
        end
    end
end