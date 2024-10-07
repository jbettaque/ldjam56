game.creature.egg = {}

game.creature.egg.health = 150
game.creature.egg.meleeDamage = 0
game.creature.egg.rangedDamage = 10
game.creature.egg.speed = 0.7
game.creature.egg.cooldown = 1.2
game.creature.egg.range = 150
game.creature.egg.backOffDistance = 75

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
                    speed = 10,
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

    -- Calculate base movement direction (either towards or away from enemy)
    local moveDirection = distance < game.creature[creature.type].backOffDistance and -1 or 1
    local moveX = math.cos(angle) * speed * moveDirection
    local moveY = math.sin(angle) * speed * moveDirection

    -- Calculate repulsion from obstacles
    local repulsionX, repulsionY = 0, 0
    local repulsionRange = radius * 3
    local repulsionStrength = 300

    for _, obstacle in ipairs(game.map.obstacles) do
        local closestX = math.max(obstacle.x, math.min(creature.x, obstacle.x + obstacle.width))
        local closestY = math.max(obstacle.y, math.min(creature.y, obstacle.y + obstacle.height))

        local dx = creature.x - closestX
        local dy = creature.y - closestY
        local obstacleDistance = math.sqrt(dx * dx + dy * dy)

        if obstacleDistance < repulsionRange then
            local repulsion = ((repulsionRange - obstacleDistance) / repulsionRange) ^ 2
            local repulsionAngle = math.atan2(dy, dx)
            repulsionX = repulsionX + math.cos(repulsionAngle) * repulsion * repulsionStrength * dt
            repulsionY = repulsionY + math.sin(repulsionAngle) * repulsion * repulsionStrength * dt
        end
    end

    -- Calculate repulsion from other creatures
    for _, otherCreature in pairs(creatureStore) do
        if otherCreature ~= creature then
            local dx = creature.x - otherCreature.x
            local dy = creature.y - otherCreature.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < radius * 3 and dist > 0 then
                local repulsion = (radius * 3 - dist) / (radius * 3)
                local repulsionAngle = math.atan2(dy, dx)
                repulsionX = repulsionX + math.cos(repulsionAngle) * repulsion * 100 * dt
                repulsionY = repulsionY + math.sin(repulsionAngle) * repulsion * 100 * dt
            end
        end
    end

    -- Calculate final position
    local newX = creature.x + moveX + repulsionX
    local newY = creature.y + moveY + repulsionY

    -- check if they are out of screen
    newX = math.max(radius, math.min(newX, screenWidth - radius))
    newY = math.max(radius, math.min(newY, screenHeight - radius))
    -- Check if new position is safe
    local canMove = true
    for _, obstacle in ipairs(game.map.obstacles) do
        if game.creature.default.isCollidingWithObstacle(newX, newY, radius, obstacle) then
            canMove = false
            break
        end
    end

    -- Apply movement
    if canMove then
        creature.x = newX
        creature.y = newY
    else
        -- Try to apply just the repulsion movement if main movement is blocked
        local safeX = creature.x + repulsionX
        local safeY = creature.y + repulsionY

        local isSafe = true
        for _, obstacle in ipairs(game.map.obstacles) do
            if game.creature.default.isCollidingWithObstacle(safeX, safeY, radius, obstacle) then
                isSafe = false
                break
            end
        end

        if isSafe then
            creature.x = safeX
            creature.y = safeY
        end
    end
end

function game.creature.egg.draw(creature)

    if creature.player == 1 then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("fill", creature.x, creature.y, 10)
    --
    --if creature.attacking then
    --    if creature.attacking.health > 0 then
    --        love.graphics.setColor(1, 0, 0)
    --        love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
    --    end
    --
    --
    --
    --end

    local projectiles = creature.projectiles or {}
    for _, projectile in ipairs(projectiles) do
        game.creature.egg.drawProjectile(projectile)
    end

end


function game.creature.egg.drawProjectile(projectile)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", projectile.x, projectile.y, 5)
end