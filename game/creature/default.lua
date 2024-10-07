game.creature.default = {}
game.creature.targetingRules = {
    toothFairy = {"tooth"},
    ghost = {"none"}
    -- Add more creature targeting rules here
}
function game.creature.default.update(dt, creature, creatureStore)

    if creature.currentCooldown > 0 then
        creature.currentCooldown = creature.currentCooldown - dt
        if creature.currentCooldown < 0 then
            creature.currentCooldown = 0
        end
    end

    if creature.damaged and creature.damaged > 0 then
        creature.damaged = creature.damaged - dt
        if creature.damaged < 0 then
            creature.damaged = 0
        end
    end

    if game.creature[creature.type].move then
        game.creature[creature.type].move(dt, creature, creatureStore)
    else
        game.creature.default.move(dt, creature, creatureStore)
    end

    if game.creature[creature.type].attack then
        game.creature[creature.type].attack(dt, creature, creatureStore)
    else
        game.creature.default.attack(dt, creature, creatureStore)
    end
end

function game.creature.default.draw(creature)
    if game.creature[creature.type].draw then
        game.creature[creature.type].draw(creature)
    else
        if creature.player == 1 then
            love.graphics.setColor(0, 0, 1)
        else
            love.graphics.setColor(1, 0, 0)
        end
        love.graphics.circle("fill", creature.x, creature.y, 10, 5)
    end

    if (creature.health < game.creature[creature.type].health) then
        local healthbarColor = creature.health / game.creature[creature.type].health
        love.graphics.setColor(0.5, healthbarColor, 0)
        love.graphics.rectangle("fill", creature.x - 10, creature.y - 15, creature.health / game.creature[creature.type].health * 20, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", creature.x - 10, creature.y - 15, 20, 5)

    end

    if creature.currentCooldown > 0 then
        love.graphics.setColor(1, 1, 1, 100)
        love.graphics.rectangle("fill", creature.x - 10, creature.y + 15, 20 * (creature.currentCooldown / game.creature[creature.type].cooldown), 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", creature.x - 10, creature.y + 15, 20, 5)

    end
end

function game.creature.default.getDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function game.creature.default.isCollidingWithObstacle(x, y, radius, obstacle)
    return x - radius < obstacle.x + obstacle.width and
            x + radius > obstacle.x and
            y - radius < obstacle.y + obstacle.height and
            y + radius > obstacle.y
end

function game.creature.default.lineIntersectsLine(x1, y1, x2, y2, x3, y3, x4, y4)
    local denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denominator == 0 then return false end

    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator
    local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator

    return t >= 0 and t <= 1 and u >= 0 and u <= 1
end

function game.creature.default.lineIntersectsRect(x1, y1, x2, y2, rect)
    local corners = {
        {rect.x, rect.y, rect.x + rect.width, rect.y},
        {rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + rect.height},
        {rect.x + rect.width, rect.y + rect.height, rect.x, rect.y + rect.height},
        {rect.x, rect.y + rect.height, rect.x, rect.y}
    }

    for _, corner in ipairs(corners) do
        if game.creature.default.lineIntersectsLine(x1, y1, x2, y2, corner[1], corner[2], corner[3], corner[4]) then
            return true
        end
    end
    return false
end

function game.creature.default.hasLineOfSight(creature, target)
    for _, obstacle in ipairs(game.map.obstacles) do
        if game.creature.default.lineIntersectsRect(creature.x, creature.y, target.x, target.y, obstacle) then
            return false
        end
    end
    return true
end

function game.creature.default.findNearestEnemy(creature, creatureStore)
    local nearestCreature, nearestTower = nil, nil
    local nearestDistance, nearestTowerDistance = math.huge, math.huge

    for _, otherCreature in ipairs(creatureStore) do
        if otherCreature ~= creature and otherCreature.player ~= creature.player then
            -- Check if the target creature type is in the rules
            local targetRules = game.creature.targetingRules[otherCreature.type]

            -- If targetRules is nil and the creature type is in the table,
            -- this means the creature cannot be targeted at all
            if targetRules == nil and game.creature.targetingRules[otherCreature.type] ~= nil then
                goto continue
            end

            -- If there are specific targeting rules, check if this creature type can attack
            if targetRules then
                local canAttack = false
                for _, allowedAttacker in ipairs(targetRules) do
                    if creature.type == allowedAttacker then
                        canAttack = true
                        break
                    end
                end
                if not canAttack then
                    goto continue
                end
            end

            local distance = game.creature.default.getDistance(creature.x, creature.y, otherCreature.x, otherCreature.y)
            if distance < nearestDistance and game.creature.default.hasLineOfSight(creature, otherCreature) then
                nearestDistance = distance
                nearestCreature = otherCreature
            end

            ::continue::
        end
    end

    for _, tower in ipairs(game.towerPlacement.towers) do
        if tower.player ~= creature.player then
            local distance = game.creature.default.getDistance(creature.x, creature.y, tower.x, tower.y)
            if distance < nearestTowerDistance then
                nearestTowerDistance = distance
                nearestTower = tower
            end
        end
    end

    return nearestTowerDistance <= nearestDistance and nearestTower or nearestCreature
end


game.creature.movement = {
    calculateEdgeRepulsion = function(creature, radius)
        local edgeBuffer = radius * 2
        local edgeRepulsionX, edgeRepulsionY = 0, 0

        if creature.x < edgeBuffer then
            edgeRepulsionX = (edgeBuffer - creature.x) * 5
        end
        if creature.x > screenWidth - edgeBuffer then
            edgeRepulsionX = (screenWidth - edgeBuffer - creature.x) * 5
        end
        if creature.y < edgeBuffer then
            edgeRepulsionY = (edgeBuffer - creature.y) * 5
        end
        if creature.y > screenHeight - edgeBuffer then
            edgeRepulsionY = (screenHeight - edgeBuffer - creature.y) * 5
        end

        return edgeRepulsionX, edgeRepulsionY
    end,

    calculateObstacleRepulsion = function(creature, radius, dt)
        local repulsionX, repulsionY = 0, 0
        local repulsionRange = radius * 4
        local repulsionStrength = 400
        local edgeBuffer = radius * 2

        for _, obstacle in ipairs(game.map.obstacles) do
            local closestX = math.max(obstacle.x, math.min(creature.x, obstacle.x + obstacle.width))
            local closestY = math.max(obstacle.y, math.min(creature.y, obstacle.y + obstacle.height))

            local dx = creature.x - closestX
            local dy = creature.y - closestY
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < repulsionRange then
                local repulsion = ((repulsionRange - distance) / repulsionRange) ^ 2
                local angle = math.atan2(dy, dx)

                -- Increase repulsion near edges
                local edgeFactor = 1
                if creature.x < edgeBuffer or creature.x > screenWidth - edgeBuffer or
                        creature.y < edgeBuffer or creature.y > screenHeight - edgeBuffer then
                    edgeFactor = 2
                end

                repulsionX = repulsionX + math.cos(angle) * repulsion * repulsionStrength * dt * edgeFactor
                repulsionY = repulsionY + math.sin(angle) * repulsion * repulsionStrength * dt * edgeFactor
            end
        end

        return repulsionX, repulsionY
    end,

    calculateCreatureRepulsion = function(creature, creatureStore, radius, dt, isEgg)
        local repulsionX, repulsionY = 0, 0
        local repulsionRange = radius * (isEgg and 4 or 3)
        local repulsionStrength = isEgg and 150 or 100

        for _, otherCreature in pairs(creatureStore) do
            if otherCreature ~= creature then
                local dx = creature.x - otherCreature.x
                local dy = creature.y - otherCreature.y
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist < repulsionRange and dist > 0 then
                    local repulsion = (repulsionRange - dist) / repulsionRange
                    local repulsionAngle = math.atan2(dy, dx)
                    repulsionX = repulsionX + math.cos(repulsionAngle) * repulsion * repulsionStrength * dt
                    repulsionY = repulsionY + math.sin(repulsionAngle) * repulsion * repulsionStrength * dt
                end
            end
        end

        return repulsionX, repulsionY
    end,

    handleStuckState = function(creature, dt, speed, safetyMargin)
        if not creature.stuckTimer then
            creature.stuckTimer = 0
            creature.lastPosition = {x = creature.x, y = creature.y}
        end

        local moveDistance = game.creature.default.getDistance(
                creature.x, creature.y,
                creature.lastPosition.x, creature.lastPosition.y
        )

        if moveDistance > speed * 0.2 then
            creature.stuckTimer = 0
            creature.lastPosition.x = creature.x
            creature.lastPosition.y = creature.y
            return false
        else
            creature.stuckTimer = creature.stuckTimer + dt
            if creature.stuckTimer > 0.5 then
                game.creature.default.damage(creature, 10 * dt)

                -- Try random movement
                local randomAngle = math.random() * math.pi * 2
                local randomDistance = speed * 2
                local testX = creature.x + math.cos(randomAngle) * randomDistance
                local testY = creature.y + math.sin(randomAngle) * randomDistance

                local isSafe = true
                for _, obstacle in ipairs(game.map.obstacles) do
                    if game.creature.default.isCollidingWithObstacle(testX, testY, safetyMargin, obstacle) then
                        isSafe = false
                        break
                    end
                end

                if isSafe then
                    creature.x = testX
                    creature.y = testY
                    return true
                end
            end
            return false
        end
    end,

    trySlideMovement = function(creature, repulsionX, repulsionY, speed, safetyMargin)
        local slideAngle = math.atan2(repulsionY, repulsionX)
        local slideX = creature.x + math.cos(slideAngle) * speed
        local slideY = creature.y + math.sin(slideAngle) * speed

        local canSlide = true
        for _, obstacle in ipairs(game.map.obstacles) do
            if game.creature.default.isCollidingWithObstacle(slideX, slideY, safetyMargin, obstacle) then
                canSlide = false
                break
            end
        end

        if canSlide then
            creature.x = slideX
            creature.y = slideY
            creature.stuckTimer = 0
            return true
        end
        return false
    end
}
function game.creature.default.move(dt, creature, creatureStore)
    local target = game.creature.default.findNearestEnemy(creature, creatureStore)
    if not target then return end

    local distance = game.creature.default.getDistance(creature.x, creature.y, target.x, target.y)
    if distance < 20 then return end

    local radius = creature.collisionRadius or 10
    local speed = 100 * dt * creature.speed
    local angleToTarget = math.atan2(target.y - creature.y, target.x - creature.x)

    -- Calculate all movement components
    local moveX = math.cos(angleToTarget) * speed
    local moveY = math.sin(angleToTarget) * speed

    local edgeRepulsionX, edgeRepulsionY = game.creature.movement.calculateEdgeRepulsion(creature, radius)
    local obstacleRepulsionX, obstacleRepulsionY = game.creature.movement.calculateObstacleRepulsion(creature, radius, dt)
    local creatureRepulsionX, creatureRepulsionY = game.creature.movement.calculateCreatureRepulsion(creature, creatureStore, radius, dt, false)

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

    if creature.type == "ghost" then
        canMove = true
        newY = creature.y + moveY
        newX = creature.x + moveX
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


function game.creature.default.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
        if nearestEnemy then

            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < 20 then
                game.creature.default.damage(nearestEnemy, creature.meleeDamage)
                nearestEnemy.health = nearestEnemy.health - creature.meleeDamage
                creature.currentCooldown = game.creature[creature.type].cooldown
                if nearestEnemy.health <= 0 then
                    for i, otherCreature in ipairs(creatureStore) do
                        if otherCreature == nearestEnemy then
                            table.remove(creatureStore, i)
                            if nearestEnemy.player == 1 then
                                game.manager.player2.money = game.manager.player2.money + 5
                            else
                                game.manager.player1.money = game.manager.player1.money + 5
                            end

                            break
                        end
                    end

                    for i, tower in ipairs(game.towerPlacement.towers) do
                        if tower == nearestEnemy then
                            table.remove(game.towerPlacement.towers, i)
                            break
                        end
                    end
                end
            end
        end
    end

end


function game.creature.default.damage(creature, damage)
    if not creature then
        return
    end
 local creatureStore = game.creatures.getCreatureStore()
    creature.damaged = 0.1
    creature.health = creature.health - damage

    -- check if creature dies
    if creature.health <= 0 then
        -- remove creature from creatureStore
        for i, otherCreature in ipairs(creatureStore) do
            if otherCreature == creature then
                table.remove(creatureStore, i)
                -- add money to the attacking player
                if creature.player == 1 then
                    game.manager.player2.money = game.manager.player2.money + 5
                else
                    game.manager.player1.money = game.manager.player1.money + 5
                end
                break
            end
        end

        -- remove tower
        for i, tower in ipairs(game.towerPlacement.towers) do
            if tower == creature then
                table.remove(game.towerPlacement.towers, i)
                break
            end
        end
    end
end