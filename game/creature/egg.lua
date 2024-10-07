game.creature.egg = {}

game.creature.egg.health = 150
game.creature.egg.meleeDamage = 0
game.creature.egg.rangedDamage = 10
game.creature.egg.speed = 0.7
game.creature.egg.cooldown = 1.2
game.creature.egg.range = 150
game.creature.egg.backOffDistance = 75
local eggImage = love.graphics.newImage("game/Sprites/Egg_Thrower.png")
function game.creature.egg.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.egg.range and distance > 20 then
                creature.currentCooldown = game.creature.egg.cooldown
                creature.attacking = nearestEnemy
                -- Schaden zufügen und die zentrale Funktion aufrufen
                game.creature.default.damage(nearestEnemy, creature.rangedDamage)
                -- Überprüfen, ob der Gegner zerstört wurde (falls health <= 0 in der damage Funktion gehandhabt wird)
                if nearestEnemy.health <= 0 then
                    creature.attacking = nil
                end

                local projectile = {
                    x = creature.x,
                    y = creature.y,
                    target = nearestEnemy,
                    speed = 20,
                    damage = creature.rangedDamage
                }

                creature.projectiles = creature.projectiles or {}
                table.insert(creature.projectiles, projectile)

            end
        end
    end
end

function game.creature.egg.move(dt, creature, creatureStore)
    local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
    if not nearestEnemy then return end

    local radius = creature.collisionRadius or 10
    local distance = game.creature.default.getDistance(creature.x, creature.y, nearestEnemy.x, nearestEnemy.y)
    local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
    local speed = 100 * dt * creature.speed

    -- Calculate movement direction with smooth transition
    local moveDirection = 1
    local transitionRange = 20
    if distance < game.creature[creature.type].backOffDistance then
        local transitionFactor = math.min(1, (game.creature[creature.type].backOffDistance - distance) / transitionRange)
        moveDirection = -transitionFactor
    end

    local moveX = math.cos(angle) * speed * moveDirection
    local moveY = math.sin(angle) * speed * moveDirection

    -- Calculate all movement components using shared functions
    local edgeRepulsionX, edgeRepulsionY = game.creature.movement.calculateEdgeRepulsion(creature, radius * 1.25)  -- Slightly larger edge buffer for eggs
    local obstacleRepulsionX, obstacleRepulsionY = game.creature.movement.calculateObstacleRepulsion(creature, radius, dt)
    local creatureRepulsionX, creatureRepulsionY = game.creature.movement.calculateCreatureRepulsion(creature, creatureStore, radius, dt, true)

    -- Calculate final position
    local newX = creature.x + moveX + obstacleRepulsionX + edgeRepulsionX * dt + creatureRepulsionX
    local newY = creature.y + moveY + obstacleRepulsionY + edgeRepulsionY * dt + creatureRepulsionY

    -- Ensure staying within bounds
    newX = math.max(radius, math.min(newX, screenWidth - radius))
    newY = math.max(radius, math.min(newY, screenHeight - radius))

    local safetyMargin = radius * 1.1
    local canMove = true

    for _, obstacle in ipairs(game.map.obstacles) do
        if game.creature.default.isCollidingWithObstacle(newX, newY, safetyMargin, obstacle) then
            canMove = false
            break
        end
    end

    if canMove then
        creature.x = newX
        creature.y = newY
        game.creature.movement.handleStuckState(creature, dt, speed, safetyMargin)
    else
        if not game.creature.movement.trySlideMovement(creature, obstacleRepulsionX + edgeRepulsionX, obstacleRepulsionY + edgeRepulsionY, speed, safetyMargin) then
            game.creature.movement.handleStuckState(creature, dt, speed, safetyMargin)
        end
    end
end

function game.creature.egg.draw(creature)


    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.20, 0.20, 32, 32)
    if (creature.player == 1) then
        transform:scale(1, 1)
    end

    love.graphics.draw(eggImage, transform)

    local projectiles = creature.projectiles or {}
    for _, projectile in ipairs(projectiles) do
        game.creature.egg.drawProjectile(projectile)
    end

end

function game.creature.egg.drawProjectile(projectile)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", projectile.x, projectile.y, 5)
end