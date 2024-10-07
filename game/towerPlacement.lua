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
        spawningCooldown = 10,
        currentSpawnCooldown = 0,
        laserTurret = true
    })

    table.insert(game.towerPlacement.towers,     {
        id = 3,
        x = 100,
        y = 300,
        spawnType = "skelleton",
        player = 1,
        health = 3000,
        maxHealth = 3000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        spawningCooldown = 10,
        currentSpawnCooldown = 0,
        laserTurret = true
    })
end
game.towerPlacement.towerTypes = {"mine", "infantry", "range", "mage", "aoe"}
game.powerType = {1, 2, 3}
game.towerPlacement.currentPlacingTower = nil

local aoeImage = love.graphics.newImage("game/Sprites/AOE_Building.png")

-- Tower type definitions
towerConfig = {
    mine = {
        health = 600,
        maxHealth = 600,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        width = 40,
        height = 30,
        spawnType = "none",
        cost = 75,
        trickle = 5,
        spawningCooldown = 20,
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
        cost = 200,
        spawnType = "skelleton",
        possibleSpawnTypes = {"carl", "dog", "horde", "skelleton"},
        spawningCooldown = 15,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
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
        cost = 250,
        spawnType = "egg",
        possibleSpawnTypes = {"egg", "tooth", "flea"},
        spawningCooldown = 25,
        draw = function(tower, mode)
            love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
        end,
        checkClick = function(x, y, tower)
            return x >= tower.x - 10 and x <= tower.x + 30 and
                    y >= tower.y - 10 and y <= tower.y + 20
        end
    },
    mage = {
        health = 1000,
        maxHealth = 1000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        radius = 20,
        cost = 500,
        spawnType = "ghost",
        possibleSpawnTypes = {"ghost", "zombie", "toothFairy"},
        spawningCooldown = 30,
        draw = function(tower, mode)
            love.graphics.circle(mode, tower.x, tower.y, 20)
        end,
        checkClick = function(x, y, tower)
            local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
            return distance <= 20
        end
    },
    aoe = {
        health = 1000,
        maxHealth = 1000,
        powerLv = 1,
        speedLv = 1,
        healthLv = 1,
        radius = 20,
        cost = 600,
        spawnType = "kamikaze",
        possibleSpawnTypes = {"kamikaze", "electro", "acid"},
        spawningCooldown = 30,
        draw = function(tower, mode)
            love.graphics.setColor(1, 1, 1)
            -- draw tower in the middle of the tile
            love.graphics.draw(aoeImage, tower.x, tower.y, 0, 0.3, 0.3, 300, 400)
        end,
        checkClick = function(x, y, tower)
            local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
            return distance <= 20
        end
    }
}
function game.towerPlacement.getTowerConfig()
    return towerConfig
end
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

local defaultFont = love.graphics.getFont() -- Store the default font size
local smallFont = love.graphics.newFont(8) -- Smaller font size (10 px, example)

function game.towerPlacement.drawTowers()

    for i, tower in ipairs(game.towerPlacement.towers) do
        drawTower(tower, "fill")
        love.graphics.setColor(1, 0, 0)

        -- Calculate the width and height of each line of text
        local totalText = "Lv: " .. (tower.type ~= "mine" and (tower.powerLv + tower.speedLv + tower.healthLv) or 1)
        local powerText = "Power: " .. (tower.powerLv or 0)
        local speedText = "Speed: " .. (tower.speedLv or 0)
        local healthText = "Health: " .. (tower.healthLv or 0)

        -- Set the font to measure text accurately
        love.graphics.setFont(defaultFont)
        local totalTextWidth = defaultFont:getWidth(totalText)
        love.graphics.setFont(smallFont)
        local subTextWidth = math.max(smallFont:getWidth(powerText), smallFont:getWidth(speedText), smallFont:getWidth(healthText))

        -- Calculate rectangle size based on the widest text and total height of all lines
        local bgWidth = math.max(totalTextWidth, subTextWidth) + 10 -- add padding
        local bgHeight
        if tower.type ~= "mine" then
            bgHeight = defaultFont:getHeight() + 3 * smallFont:getHeight() + 15 -- include spacing and padding for sub-levels
        else
            bgHeight = defaultFont:getHeight() + 10 -- padding for "Lv: 1" only
        end
        local cornerRadius = 8 -- Corner radius for rounded corners

        -- Draw the background with rounded corners
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8) -- Dark, semi-transparent background
        love.graphics.rectangle("fill", tower.x + 30, tower.y - 15, bgWidth, bgHeight, cornerRadius, cornerRadius)
        love.graphics.setColor(1, 1, 1, 1) -- Dark, semi-transparent background
        love.graphics.rectangle("line", tower.x + 30, tower.y - 15, bgWidth, bgHeight, cornerRadius, cornerRadius)
        -- Display the text content
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(defaultFont)

        if tower.type ~= "mine" then
            -- Display total level (default font size)
            love.graphics.print(totalText, tower.x + 35, tower.y - 10)

            -- Display sub-levels in smaller font size
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.8, 0, 0)
            love.graphics.print(powerText, tower.x + 35, tower.y + 5)
            love.graphics.setColor(0, 0, 0.8)
            love.graphics.print(speedText, tower.x + 35, tower.y + 14)
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.print(healthText, tower.x + 35, tower.y + 23)
        else
            -- Display only "Lv: 1" for mines
            love.graphics.print("Lv: 1", tower.x + 35, tower.y - 10)
        end

        -- Reset font to default
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 0, 0) -- Reset color for other drawings

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
    return newTower
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
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", tower.x, tower.y, 100)
            love.graphics.circle("line", tower.x, tower.y, 101)
        end
    end
end