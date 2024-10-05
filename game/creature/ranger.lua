game.creature.ranger = {}

game.creature.ranger.health = 50
game.creature.ranger.meleeDamage = 0
game.creature.ranger.rangedDamage = 15
game.creature.ranger.speed = 0.7
game.creature.ranger.cooldown = 1
game.creature.ranger.range = 150

function game.creature.ranger.attack(dt, creature, creatureStore)
    if love.timer.getTime() % 0.3 < 0.1 then
        print("Ranger attacking")
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.ranger.range and distance > 20 then
                print("Ranger attacking and in range")
                nearestEnemy.health = nearestEnemy.health - creature.rangedDamage * dt
                if nearestEnemy.health <= 0 then
                    for i, otherCreature in ipairs(creatureStore) do
                        if otherCreature == nearestEnemy then
                            table.remove(creatureStore, i)
                            break
                        end
                    end

                    for i, tower in ipairs(game.towerPlacement.towers) do
                        if tower == nearestEnemy then
                            print("Tower destroyed")
                            table.remove(game.towerPlacement.towers, i)
                            break
                        end
                    end
                end
            end
        end

    end

end


function game.creature.ranger.move(dt, creature, creatureStore)


    local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

    -- if too close to enemy, flee
    if nearestEnemy then
        local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
        if distance < 100 then
            local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
            creature.x = creature.x - math.cos(angle) * 100 * dt * creature.speed
            creature.y = creature.y - math.sin(angle) * 100 * dt * creature.speed
        else
            local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
            creature.x = creature.x + math.cos(angle) * 100 * dt * creature.speed
            creature.y = creature.y + math.sin(angle) * 100 * dt * creature.speed
        end
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