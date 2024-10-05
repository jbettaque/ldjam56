game.creature.default = {}

function game.creature.default.update(dt, creature, creatureStore)

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

function game.creature.default.findNearestEnemy(creature, creatureStore)
    local nearestEnemy = nil
    local nearestDistance = 1000000
    for i, otherCreature in ipairs(creatureStore) do
        if otherCreature ~= creature and otherCreature.player ~= creature.player then
            local distance = math.sqrt((creature.x - otherCreature.x)^2 + (creature.y - otherCreature.y)^2)
            if distance < nearestDistance then
                nearestDistance = distance
                nearestEnemy = otherCreature
            end
        end
    end
    return nearestEnemy
end

function game.creature.default.move(dt, creature, creatureStore)
    local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
    if nearestEnemy then
        local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
        if distance < 20 then
            return
        end
        local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
        creature.x = creature.x + math.cos(angle) * 100 * dt * creature.speed
        creature.y = creature.y + math.sin(angle) * 100 * dt * creature.speed
    end

    local collisionRadius = creature.collisionRadius or 10  -- Set a default collision radius if not defined

    for _, otherCreature in pairs(creatureStore) do
        if otherCreature ~= creature then
            local dx = creature.x - otherCreature.x
            local dy = creature.y - otherCreature.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < 2 * collisionRadius and dist > 0 then  -- If creatures are overlapping
                -- Calculate repulsion force to push them apart
                local overlap = 2 * collisionRadius - dist
                local repulsionAngle = math.atan2(dy, dx)
                creature.x = creature.x + math.cos(repulsionAngle) * overlap * 0.5
                creature.y = creature.y + math.sin(repulsionAngle) * overlap * 0.5
            end
        end
    end
end

function game.creature.default.attack(dt, creature, creatureStore)
    if love.timer.getTime() % 1 < 0.1 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < 20 then
                nearestEnemy.health = nearestEnemy.health - 10 * dt
                if nearestEnemy.health <= 0 then
                    for i, otherCreature in ipairs(creatureStore) do
                        if otherCreature == nearestEnemy then
                            table.remove(creatureStore, i)
                            break
                        end
                    end
                end
            end
        end
    end

end
