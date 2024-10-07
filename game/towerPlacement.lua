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
local paranormalImage = love.graphics.newImage("game/Sprites/Paranomal_Building.png")

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
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(paranormalImage, tower.x, tower.y, 0, 0.2, 0.2, 300, 400)
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
            love.graphics.draw(aoeImage, tower.x, tower.y, 0, 0.2, 0.2, 300, 400)
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

local displayRadius = 100 -- Radius around the mouse to display tower stats
local defaultFont = love.graphics.getFont() -- Store the default font size
local smallFont = love.graphics.newFont(8) -- Smaller font size for sub-levels

-- Function to check if a tower is within the radius of the mouse
local function isTowerWithinRadius(tower, mouseX, mouseY, radius)
    local distance = math.sqrt((tower.x - mouseX)^2 + (tower.y - mouseY)^2)
    return distance <= radius
end

function game.towerPlacement.drawTowers()
    -- Draw each tower normally
    for _, tower in ipairs(game.towerPlacement.towers) do
        drawTower(tower, "fill")
    end

    -- Get mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Iterate over towers to display stats for those within radius
    for _, tower in ipairs(game.towerPlacement.towers) do
        if isTowerWithinRadius(tower, mouseX, mouseY, displayRadius) then
            -- Get the tower type
            local typeText = tower.type or "HQ"

            if typeText ~= "mine" and typeText ~= "HQ" then
                -- Activate code for towers that are not "mine" or "HQ"

                -- Prepare tower stats text
                local totalText = "Lv: " .. (tower.powerLv + tower.speedLv + tower.healthLv)
                local powerText = "Power: " .. (tower.powerLv or 0)
                local speedText = "Speed: " .. (tower.speedLv or 0)
                local healthText = "Health: " .. (tower.healthLv or 0)
                local spawnTypeText = "Spawn: " .. (tower.spawnType or "None")  -- Added label for consistency

                -- Set fonts to measure text accurately
                love.graphics.setFont(defaultFont)
                local typeTextWidth = defaultFont:getWidth(typeText)
                local totalTextWidth = defaultFont:getWidth(totalText)
                local defaultFontHeight = defaultFont:getHeight()

                love.graphics.setFont(smallFont)
                local powerTextWidth = smallFont:getWidth(powerText)
                local speedTextWidth = smallFont:getWidth(speedText)
                local healthTextWidth = smallFont:getWidth(healthText)
                local spawnTypeTextWidth = smallFont:getWidth(spawnTypeText)
                local smallFontHeight = smallFont:getHeight()

                -- Calculate rectangle width based on the widest text
                local bgWidth = math.max(
                        typeTextWidth,
                        totalTextWidth,
                        powerTextWidth,
                        speedTextWidth,
                        healthTextWidth,
                        spawnTypeTextWidth
                ) + 10  -- Add padding

                -- Calculate rectangle height based on the total height of all lines plus padding
                local bgHeight = defaultFontHeight * 2 + smallFontHeight * 4 + 20  -- Adjusted padding

                local cornerRadius = 8

                -- Determine position based on tower's location
                local screenWidth = love.graphics.getWidth()
                local offsetX

                if tower.x > screenWidth / 2 then
                    -- Tower is on the right half; display rectangle to the left
                    offsetX = -15 - bgWidth
                else
                    -- Tower is on the left half; display rectangle to the right
                    offsetX = 35
                end

                -- Draw background with rounded corners next to the tower
                love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
                love.graphics.rectangle("fill", tower.x + offsetX, tower.y - bgHeight / 2, bgWidth, bgHeight, cornerRadius, cornerRadius)
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", tower.x + offsetX, tower.y - bgHeight / 2, bgWidth, bgHeight, cornerRadius, cornerRadius)

                -- Display the text content next to the tower position
                local textX = tower.x + offsetX + 5  -- Starting X position for text (5 pixels inside the rectangle)
                local textY = tower.y - bgHeight / 2 + 5  -- Starting Y position for text

                love.graphics.setColor(1, 1, 1)
                love.graphics.setFont(defaultFont)
                love.graphics.print(typeText, textX, textY)  -- Type at the top
                textY = textY + defaultFontHeight  -- Move down for next line
                love.graphics.print(totalText, textX, textY)
                textY = textY + defaultFontHeight
                love.graphics.setFont(smallFont)
                love.graphics.setColor(0.8, 0, 0)
                love.graphics.print(powerText, textX, textY)
                textY = textY + smallFontHeight
                love.graphics.setColor(0, 0, 0.8)
                love.graphics.print(speedText, textX, textY)
                textY = textY + smallFontHeight
                love.graphics.setColor(0, 0.8, 0)
                love.graphics.print(healthText, textX, textY)
                textY = textY + smallFontHeight
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(spawnTypeText, textX, textY)
            else
                -- Place a rectangle next to the tower that just contains the typeText

                -- Set the font to measure text accurately
                love.graphics.setFont(defaultFont)
                local typeTextWidth = defaultFont:getWidth(typeText)
                local defaultFontHeight = defaultFont:getHeight()

                -- Calculate rectangle size based on the width of typeText
                local bgWidth = typeTextWidth + 10  -- Add padding
                local bgHeight = defaultFontHeight + 10  -- Add padding
                local cornerRadius = 8

                -- Determine position based on tower's location
                local screenWidth = love.graphics.getWidth()
                local offsetX

                if tower.x > screenWidth / 2 then
                    offsetX = -15 - bgWidth
                else
                    offsetX = 35
                end

                -- Draw background with rounded corners next to the tower
                love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
                love.graphics.rectangle("fill", tower.x + offsetX, tower.y - bgHeight / 2, bgWidth, bgHeight, cornerRadius, cornerRadius)
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", tower.x + offsetX, tower.y - bgHeight / 2, bgWidth, bgHeight, cornerRadius, cornerRadius)

                -- Display the typeText next to the tower position
                love.graphics.setColor(1, 1, 1)
                love.graphics.setFont(defaultFont)
                love.graphics.print(typeText, tower.x + offsetX + 5, tower.y - bgHeight / 2 + 5)
            end
        end

        love.graphics.setColor(1, 0, 0)



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