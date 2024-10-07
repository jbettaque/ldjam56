game.creature.flea = {}

game.creature.flea.health = 150
game.creature.flea.meleeDamage = 0
game.creature.flea.rangedDamage = 2
game.creature.flea.speed = 0.7
game.creature.flea.cooldown = 0.2
game.creature.flea.range = 350
game.creature.flea.backOffDistance = 100

local fleaImage = love.graphics.newImage("game/Sprites/Flea_Granade_Shooter.png")

function game.creature.flea.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.flea.range and distance > 20 then
                creature.currentCooldown = game.creature.flea.cooldown
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
                    speed = 7,
                    damage = creature.rangedDamage
                }

                creature.projectiles = creature.projectiles or {}
                table.insert(creature.projectiles, projectile)

            end
        end
    end
end


function game.creature.flea.move(dt, creature, creatureStore)

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

function game.creature.flea.draw(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.2, 0.2, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(fleaImage, transform)

    local projectiles = creature.projectiles or {}
    for _, projectile in ipairs(projectiles) do
        game.creature.flea.drawProjectile(projectile)
    end

end

function game.creature.flea.drawProjectile(projectile)
    love.graphics.setColor(0.3, 1, 0.2)

    for i = 1, 10 do
        local randomX = love.math.random(-5, 5)
        local randomY = love.math.random(-5, 5)
        love.graphics.circle("fill", projectile.x + randomX, projectile.y + randomY, 2)
    end


end