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

        if (creature.health < game.creature[creature.type].health) then
            local healthbarColor = creature.health / game.creature[creature.type].health
            love.graphics.setColor(0.5, healthbarColor, 0)
            love.graphics.rectangle("fill", creature.x - 10, creature.y - 15, creature.health / game.creature[creature.type].health * 20, 5)
        end
    end

    if creature.currentCooldown > 0 then
        love.graphics.setColor(1, 1, 1, 100)
        love.graphics.rectangle("fill", creature.x - 10, creature.y + 15, 20 * (creature.currentCooldown / game.creature[creature.type].cooldown), 5)


    end
end

function game.creature.default.findNearestEnemy(creature, creatureStore)
    local nearestCreature = nil
    local nearestDistance = 1000000
    for i, otherCreature in ipairs(creatureStore) do
        if otherCreature ~= creature and otherCreature.player ~= creature.player then
            local distance = math.sqrt((creature.x - otherCreature.x)^2 + (creature.y - otherCreature.y)^2)
            if distance < nearestDistance then
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
            if distance < nearestTowerDistance then
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
