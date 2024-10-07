game.creature.tooth = {}

game.creature.tooth.health = 150
game.creature.tooth.meleeDamage = 0
game.creature.tooth.rangedDamage = 10
game.creature.tooth.speed = 0.7
game.creature.tooth.cooldown = 1.2
game.creature.tooth.range = 150
game.creature.tooth.backOffDistance = 75

function game.creature.tooth.attack(dt, creature, creatureStore)
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
                    speed = 25,
                    damage = creature.rangedDamage
                }

                creature.projectiles = creature.projectiles or {}
                table.insert(creature.projectiles, projectile)

            end
        end
    end
end


function game.creature.tooth.move(dt, creature, creatureStore)
    game.creature.egg.move(dt, creature, creatureStore)

    --local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
    --
    ---- if too close to enemy, flee
    --if nearestEnemy then
    --    local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
    --    if distance < game.creature[creature.type].backOffDistance then
    --        local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
    --        creature.x = creature.x - math.cos(angle) * 100 * dt * creature.speed
    --        creature.y = creature.y - math.sin(angle) * 100 * dt * creature.speed
    --    else
    --        local angle = math.atan2(nearestEnemy.y - creature.y, nearestEnemy.x - creature.x)
    --        creature.x = creature.x + math.cos(angle) * 100 * dt * creature.speed
    --        creature.y = creature.y + math.sin(angle) * 100 * dt * creature.speed
    --    end
    --end
    --
    --
    --
    --
    --local collisionRadius = creature.collisionRadius or 10  -- Set a default collision radius if not defined
    --
    --for _, otherCreature in pairs(creatureStore) do
    --    if otherCreature ~= creature then
    --        local dx = creature.x - otherCreature.x
    --        local dy = creature.y - otherCreature.y
    --        local dist = math.sqrt(dx * dx + dy * dy)
    --
    --        if dist < 2 * collisionRadius and dist > 0 then  -- If creatures are overlapping
    --            -- Calculate repulsion force to push them apart
    --            local overlap = 2 * collisionRadius - dist
    --            local repulsionAngle = math.atan2(dy, dx)
    --            creature.x = creature.x + math.cos(repulsionAngle) * overlap * 0.5
    --            creature.y = creature.y + math.sin(repulsionAngle) * overlap * 0.5
    --        end
    --    end
    --end
end

function game.creature.tooth.draw(creature)

    if creature.player == 1 then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("fill", creature.x, creature.y, 10)

    if creature.attacking then
        if creature.attacking.health > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
        end
    end

    local projectiles = creature.projectiles or {}
    for _, projectile in ipairs(projectiles) do
        game.creature.tooth.drawProjectile(projectile)
    end

end


function game.creature.tooth.drawProjectile(projectile)
    love.graphics.setColor(1, 1, 1)
    -- simple toothshape made with love.graphics.polygon (two triangles and one rectangle)
    local x, y = projectile.x, projectile.y
    local toothVertices = {
        x + 5,    y,        -- Right center
        x + 2.5,  y + 2.5,  -- Top right
        x -2.5,   y + 3.5,  -- Top crown side
        x -7.5,   y + 1.5,  -- Top root tip
        x -5,     y,        -- Left center
        x -7.5,   y -1.5,   -- Bottom root tip
        x -2.5,   y -3.5,   -- Bottom crown side
        x + 2.5,  y -2.5    -- Bottom right
    }

    -- Set the color of the tooth (optional)
    love.graphics.setColor(1, 1, 1)  -- White color

    -- Draw the tooth polygon
    love.graphics.polygon("fill", toothVertices)


end