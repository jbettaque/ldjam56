game.creature.default = {}

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

-- Function to check if there is a clear line of sight between two points


-- Helper function to check if a line intersects a rectangle (obstacle)
function lineIntersectsRect(x1, y1, x2, y2, rect)
    -- Define the four corners of the rectangle
    local rectX1, rectY1 = rect.x, rect.y
    local rectX2, rectY2 = rect.x + rect.width, rect.y
    local rectX3, rectY3 = rect.x + rect.width, rect.y + rect.height
    local rectX4, rectY4 = rect.x, rect.y + rect.height

    -- Check if the line intersects any of the four edges of the rectangle
    return lineIntersectsLine(x1, y1, x2, y2, rectX1, rectY1, rectX2, rectY2) or
            lineIntersectsLine(x1, y1, x2, y2, rectX2, rectY2, rectX3, rectY3) or
            lineIntersectsLine(x1, y1, x2, y2, rectX3, rectY3, rectX4, rectY4) or
            lineIntersectsLine(x1, y1, x2, y2, rectX4, rectY4, rectX1, rectY1)
end

-- Helper function to check if two lines intersect
function lineIntersectsLine(x1, y1, x2, y2, x3, y3, x4, y4)
    -- Calculate direction of the lines
    local denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denominator == 0 then
        return false  -- Lines are parallel and don't intersect
    end

    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator
    local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator

    return t >= 0 and t <= 1 and u >= 0 and u <= 1
end

-- Updated findNearestEnemy function with line of sight check
function game.creature.default.findNearestEnemy(creature, creatureStore)
    local nearestCreature = nil
    local nearestDistance = 1000000
    for i, otherCreature in ipairs(creatureStore) do
        if otherCreature ~= creature and otherCreature.player ~= creature.player then
            local distance = math.sqrt((creature.x - otherCreature.x)^2 + (creature.y - otherCreature.y)^2)
            if distance < nearestDistance and hasLineOfSight(creature, otherCreature) then
                nearestDistance = distance
                nearestCreature = otherCreature
            end
        end
    end

    local nearestTower = nil
    local nearestTowerDistance = 1000000
    for i, tower in ipairs(game.towerPlacement.towers) do
        if tower.player ~= creature.player then
            local distance = math.sqrt((creature.x - tower.x)^2 + (creature.y - tower.y)^2)
            if distance < nearestTowerDistance  then
                nearestTowerDistance = distance
                nearestTower = tower
            end
        end
    end

    if nearestTowerDistance <= nearestDistance then
        return nearestTower
    else
        return nearestCreature
    end
end
function hasLineOfSight(creature, target)
    for _, obstacle in ipairs(game.map.obstacles) do
        if lineIntersectsRect(creature.x, creature.y, target.x, target.y, obstacle) then
            return false
        end
    end
    return true
end

function game.creature.default.tryMoveCreature(creature, newX, newY, dt)
    local collisionRadius = creature.collisionRadius or 10  -- Default collision radius

    -- Check for collisions with obstacles
    local canMove = true
    for _, obstacle in ipairs(game.map.obstacles) do
        local testCreature = {x = newX, y = newY, collisionRadius = collisionRadius}
        if game.creature.default.isCollidingWithObstacle(testCreature, obstacle) then
            canMove = false
            break
        end
    end

    -- If it can move to the new position, update the creature's position
    if canMove then
        creature.x = newX
        creature.y = newY
        return true
    end

    return false
end
function game.creature.default.isLookingAtObstacle(creature, angle, distance)
    local lookX = creature.x + math.cos(angle) * distance
    local lookY = creature.y + math.sin(angle) * distance

    for _, obstacle in ipairs(game.map.obstacles) do
        local testCreature = {x = lookX, y = lookY, collisionRadius = creature.collisionRadius or 10}
        if game.creature.default.isCollidingWithObstacle(testCreature, obstacle) then
            return true
        end
    end
    return false
end
function getDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- Find the best direction to move around an obstacle
local function findObstacleBypassDirection(creature, target, obstacle)
    local creatureToTarget = math.atan2(target.y - creature.y, target.x - creature.x)

    -- Calculate four corner points of the obstacle
    local corners = {
        {x = obstacle.x, y = obstacle.y},                           -- Top-left
        {x = obstacle.x + obstacle.width, y = obstacle.y},          -- Top-right
        {x = obstacle.x + obstacle.width, y = obstacle.y + obstacle.height}, -- Bottom-right
        {x = obstacle.x, y = obstacle.y + obstacle.height}          -- Bottom-left
    }

    -- Find the closest corner to create a waypoint
    local bestCorner = nil
    local bestScore = math.huge
    for _, corner in ipairs(corners) do
        local distToCorner = getDistance(creature.x, creature.y, corner.x, corner.y)
        local cornerToTarget = getDistance(corner.x, corner.y, target.x, target.y)
        local score = distToCorner + cornerToTarget

        -- Check if path to corner is clear
        local blocked = false
        for _, obs in ipairs(game.map.obstacles) do
            if obs ~= obstacle and lineIntersectsRect(creature.x, creature.y, corner.x, corner.y, obs) then
                blocked = true
                break
            end
        end

        if not blocked and score < bestScore then
            bestScore = score
            bestCorner = corner
        end
    end

    if bestCorner then
        return math.atan2(bestCorner.y - creature.y, bestCorner.x - creature.x)
    end

    -- Fallback to simple avoidance if no good corner found
    return creatureToTarget + (math.random() > 0.5 and math.pi/2 or -math.pi/2)
end

function game.creature.default.isCollidingWithObstacle(x, y, radius, obstacle)
    return x - radius < obstacle.x + obstacle.width and
            x + radius > obstacle.x and
            y - radius < obstacle.y + obstacle.height and
            y + radius > obstacle.y
end

function game.creature.default.findPath(creature, target)
    local angleToTarget = math.atan2(target.y - creature.y, target.x - creature.x)
    local radius = creature.collisionRadius or 10

    -- Check if direct path is clear
    local directBlocked = false
    local blockingObstacle = nil
    for _, obstacle in ipairs(game.map.obstacles) do
        if lineIntersectsRect(creature.x, creature.y, target.x, target.y, obstacle) then
            directBlocked = true
            blockingObstacle = obstacle
            break
        end
    end

    -- If path is clear and not near any obstacle edges, go direct
    if not directBlocked then
        return angleToTarget
    end

    -- If near an obstacle, find bypass direction
    if blockingObstacle then
        return findObstacleBypassDirection(creature, target, blockingObstacle)
    end

    -- Fallback pathfinding with multiple angle checks
    local alternatives = {
        {angle = 0, weight = 1},
        {angle = math.pi/6, weight = 0.9},
        {angle = -math.pi/6, weight = 0.9},
        {angle = math.pi/3, weight = 0.7},
        {angle = -math.pi/3, weight = 0.7}
    }

    local bestAngle = angleToTarget
    local bestScore = -1

    for _, alt in ipairs(alternatives) do
        local testAngle = angleToTarget + alt.angle
        local testX = creature.x + math.cos(testAngle) * 30
        local testY = creature.y + math.sin(testAngle) * 30

        local blocked = false
        for _, obstacle in ipairs(game.map.obstacles) do
            if game.creature.default.isCollidingWithObstacle(testX, testY, radius, obstacle) then
                blocked = true
                break
            end
        end

        if not blocked then
            local distanceScore = 1 / (1 + getDistance(testX, testY, target.x, target.y))
            local score = distanceScore * alt.weight

            if score > bestScore then
                bestScore = score
                bestAngle = testAngle
            end
        end
    end

    return bestAngle
end

function game.creature.default.move(dt, creature, creatureStore)
    -- Find nearest enemy target
    local target = game.creature.default.findNearestEnemy(creature, creatureStore)
    if not target then return end

    -- Check if we're already in attack range
    local distance = getDistance(creature.x, creature.y, target.x, target.y)
    if distance < 20 then return end

    -- Calculate base movement values
    local speed = 100 * dt * creature.speed
    local angleToTarget = math.atan2(target.y - creature.y, target.x - creature.x)
    local radius = creature.collisionRadius or 10

    -- Initialize movement and repulsion vectors
    local moveX = math.cos(angleToTarget) * speed
    local moveY = math.sin(angleToTarget) * speed
    local repulsionX, repulsionY = 0, 0

    -- Repulsion parameters
    local repulsionStrength = 300
    local repulsionRange = radius * 3
    local sideStepStrength = 200

    -- Track if there's an obstacle directly ahead
    local isBlockedAhead = false
    local nearestObstacleDistance = math.huge

    -- Calculate repulsion from all obstacles
    for _, obstacle in ipairs(game.map.obstacles) do
        -- Find closest point on obstacle to creature
        local closestX = math.max(obstacle.x, math.min(creature.x, obstacle.x + obstacle.width))
        local closestY = math.max(obstacle.y, math.min(creature.y, obstacle.y + obstacle.height))

        -- Calculate distance and direction from creature to closest point
        local dx = creature.x - closestX
        local dy = creature.y - closestY
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Check if this obstacle is directly ahead
        local angleToObstacle = math.atan2(dy, dx)
        local angleDiff = math.abs(angleToObstacle - angleToTarget)
        while angleDiff > math.pi do
            angleDiff = math.abs(angleDiff - 2 * math.pi)
        end

        if distance < nearestObstacleDistance and angleDiff < math.pi / 4 then
            nearestObstacleDistance = distance
            if distance < repulsionRange then
                isBlockedAhead = true
            end
        end

        -- Apply repulsion if within range
        if distance < repulsionRange then
            local repulsion = (repulsionRange - distance) / repulsionRange
            repulsion = repulsion * repulsion -- Square for stronger close-range repulsion
            local angle = math.atan2(dy, dx)
            repulsionX = repulsionX + math.cos(angle) * repulsion * repulsionStrength * dt
            repulsionY = repulsionY + math.sin(angle) * repulsion * repulsionStrength * dt
        end
    end

    -- If blocked ahead, always try to go right first
    if isBlockedAhead then
        -- Add rightward movement (perpendicular to movement direction)
        local sideAngle = angleToTarget + math.pi/2  -- Add 90 degrees to go right
        repulsionX = repulsionX + math.cos(sideAngle) * sideStepStrength * dt
        repulsionY = repulsionY + math.sin(sideAngle) * sideStepStrength * dt

        -- Reduce forward movement when blocked
        moveX = moveX * 0.3  -- Reduced more to emphasize sideways movement
        moveY = moveY * 0.3
    end

    -- Combine movement and repulsion vectors
    local finalX = creature.x + moveX + repulsionX
    local finalY = creature.y + moveY + repulsionY

    -- Final collision check
    local canMove = true
    for _, obstacle in ipairs(game.map.obstacles) do
        if game.creature.default.isCollidingWithObstacle(finalX, finalY, radius, obstacle) then
            canMove = false
            break
        end
    end

    -- Apply movement if safe, otherwise just apply repulsion
    if canMove then
        creature.x = finalX
        creature.y = finalY
    else
        -- Apply just repulsion with a minimum movement to prevent complete sticking
        local minMove = 5 * dt
        local moveAmount = math.max(math.sqrt(repulsionX * repulsionX + repulsionY * repulsionY), minMove)
        local moveAngle = math.atan2(repulsionY, repulsionX)

        local safeX = creature.x + math.cos(moveAngle) * moveAmount
        local safeY = creature.y + math.sin(moveAngle) * moveAmount

        -- Check if this minimum movement is safe
        local safeMovePosition = true
        for _, obstacle in ipairs(game.map.obstacles) do
            if game.creature.default.isCollidingWithObstacle(safeX, safeY, radius, obstacle) then
                safeMovePosition = false
                break
            end
        end

        if safeMovePosition then
            creature.x = safeX
            creature.y = safeY
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