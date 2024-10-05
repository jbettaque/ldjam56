game.towerPlacement = {}

game.towerPlacement.towers = {}
game.towerPlacement.towerTypes = {"circle", "rectangle", "image"}
game.powerType = {1, 2, 3}
game.towerPlacement.currentPlacingTower = nil

-- Tower type definitions
local towerConfig = {
    circle = {
        health = 1000,
        powerLv = 10,
        radius = 20,
        spawnType = "ranger",
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
        powerLv = 8,
        width = 40,
        height = 30,
        spawnType = "attacker",
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
        powerLv = 12,
        width = 40,
        height = 40,
        spawnType = "bomber",
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
        health = config.health,
        powerLv = config.powerLv
    }
    game.towerPlacement.currentPlacingTower = newTower
    return newTower
end

function game.towerPlacement.addTower(tower)
    if tower then
        table.insert(game.towerPlacement.towers, tower)
    end
end

function game.towerPlacement.drawTowers()
    for i, tower in ipairs(game.towerPlacement.towers) do
        drawTower(tower, "fill")
    end
    if game.towerPlacement.currentPlacingTower then
        drawTower(game.towerPlacement.currentPlacingTower, "line")
    end
end

function drawTower(tower, mode)
    if tower.player == 1 then
        love.graphics.setColor(0, 2, 9)
    else
        love.graphics.setColor(1, 0, 0)
    end

    local config = towerConfig[tower.type]
    if config and config.draw then
        config.draw(tower, mode)
    end
end

function isClickOnTower(x, y, tower)
    local config = towerConfig[tower.type]
    if config and config.checkClick then
        return config.checkClick(x, y, tower)
    end
    return false
end

-- Helper function to add new tower types
function game.towerPlacement.addTowerType(typeName, config)
    if not towerConfig[typeName] then
        towerConfig[typeName] = config
        table.insert(game.towerPlacement.towerTypes, typeName)
    end
end

-- Example of how to add a new tower type:
--[[
game.towerPlacement.addTowerType("hexagon", {
    health = 900,
    powerLv = 11,
    radius = 25,
    draw = function(tower, mode)
        -- Draw hexagon logic here
        local sides = 6
        local radius = 25
        local angle = 2 * math.pi / sides
        local points = {}
        for i = 1, sides do
            table.insert(points, tower.x + radius * math.cos(i * angle))
            table.insert(points, tower.y + radius * math.sin(i * angle))
        end
        love.graphics.polygon(mode, points)
    end,
    checkClick = function(x, y, tower)
        local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
        return distance <= 25
    end
})
--]]