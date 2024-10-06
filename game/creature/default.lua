game.creature.default = {}

function game.creature.default.update(dt, creature, creatureStore)

    if creature.currentCooldown > 0 then
        creature.currentCooldown = creature.currentCooldown - dt
        if creature.currentCooldown < 0 then
            creature.currentCooldown = 0
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
function hasLineOfSight(creature, target)
    local creatureX, creatureY = creature.x, creature.y
    local targetX, targetY = target.x, target.y

    -- Iterate over all obstacles to check if any of them blocks the line of sight
    for _, obstacle in ipairs(game.map.obstacles) do
        if lineIntersectsRect(creatureX, creatureY, targetX, targetY, obstacle) then
            return false  -- Line of sight is blocked by an obstacle
        end
    end

    return true  -- No obstacles block the line of sight
end

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

function game.creature.default.isCollidingWithObstacle(creature, obstacle)
    local collisionRadius = creature.collisionRadius or 10  -- Default radius if not defined
    return creature.x - collisionRadius < obstacle.x + obstacle.width and
            creature.x + collisionRadius > obstacle.x and
            creature.y - collisionRadius < obstacle.y + obstacle.height and
            creature.y + collisionRadius > obstacle.y
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
local function getOppositeSidePoint(player)
    if player == 1 then
        return { x = screenWidth, y = screenHeight / 2 }  -- Opposite side for player 1
    else
        return { x = 0, y = screenHeight / 2 }  -- Opposite side for player 2
    end
end
function game.creature.default.move(dt, creature, creatureStore)
    local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

    -- If the creature has been stuck for too long, set a new goal
    if creature.stuckTime > 3 then  -- Example: 3 seconds of being stuck
        -- Set the creature's goal to the opposite side of the map
        if creature.player == 1 then
            -- For player 1, set the goal to the opposite side of the map
            nearestEnemy = { x = screenWidth - creature.x, y = creature.y }
        elseif creature.player == 2 then
            -- For player 2, set the goal to a different position (e.g., (0, 0))
            nearestEnemy = { x = 0, y = creature.y }
        end
    end

    if nearestEnemy then
        local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
        if distance < 20 then
            return  -- Too close, stop moving
        end

        -- Calculate angle towards the enemy
        local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
        local speed = 100 * dt * creature.speed

        -- Distance to check for obstacles in front of the creature
        local lookAheadDistance = 20

        -- Check if there's an obstacle in the direction the creature is looking
        if not game.creature.default.isLookingAtObstacle(creature, angle, lookAheadDistance) then
            -- If no obstacle, move forward
            local newX = creature.x + math.cos(angle) * speed
            local newY = creature.y + math.sin(angle) * speed

            -- Try moving the creature
            if game.creature.default.tryMoveCreature(creature, newX, newY, dt) then
                -- Creature moved, reset the stuck timer
                creature.stuckTime = 0
                creature.lastPosition = { x = creature.x, y = creature.y }
                return
            end
        end

        -- If blocked, attempt small angular adjustments
        local angleOffset = math.pi / 4 -- Try smaller 11.25-degree shifts
        local maxAttempts = 12  -- Total attempts for angle adjustments (6 left, 6 right)

        local moved = false
        for i = 1, maxAttempts do
            local tx = (screenHeight/2 - creature.x ) / math.abs((screenHeight/2 - creature.x ))
            local oppositePoint = getOppositeSidePoint(creature.player)  -- Get the opposite side point for the creature's player
            local adjustedAngle = ((angle + (i * angleOffset) * (i % 2 == 0 and 1 or -1) ) + math.atan2(oppositePoint.y - creature.y, oppositePoint.x - creature.x)) / 2
            local adjustedX = creature.x + math.cos(adjustedAngle) * speed
            local adjustedY = creature.y + math.sin(adjustedAngle) * speed

            -- Try moving in the adjusted direction
            if game.creature.default.tryMoveCreature(creature, adjustedX, adjustedY, dt) then
                moved = true
                creature.stuckTime = 0  -- Reset stuck time if successful
                break
            end
        end

        -- If the creature didn't move, increase the stuck timer
        if not moved then
            creature.stuckTime = creature.stuckTime + dt
        end
    end

    -- Repulsion logic (keep creatures from overlapping)
    local collisionRadius = creature.collisionRadius or 10  -- Default collision radius
    for _, otherCreature in pairs(creatureStore) do
        if otherCreature ~= creature then
            local dx = creature.x - otherCreature.x
            local dy = creature.y - otherCreature.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < 2 * collisionRadius and dist > 0 then  -- If creatures are overlapping
                -- Calculate repulsion force to push them apart
                local overlap = 2 * collisionRadius - dist
                local repulsionAngle = math.atan2(dy, dx)

                -- Calculate smoother repulsion movement
                local newX = creature.x + math.cos(repulsionAngle) * overlap * 0.3
                local newY = creature.y + math.sin(repulsionAngle) * overlap * 0.3

                -- Ensure creature isn't pushed into an obstacle
                if game.creature.default.tryMoveCreature(creature, newX, newY, dt) then
                    break
                end
            end
        end
    end
end


function game.creature.default.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < 20 then
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
