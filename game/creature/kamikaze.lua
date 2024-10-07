game.creature.kamikaze = {}

game.creature.kamikaze.health = 150
game.creature.kamikaze.meleeDamage = 0
game.creature.kamikaze.rangedDamage = 300
game.creature.kamikaze.speed = 1
game.creature.kamikaze.cooldown = 2.5
game.creature.kamikaze.range = 30
game.creature.kamikaze.bombRange = 200

local kamikazeImage = love.graphics.newImage("game/Sprites/Kamikaze.png")

function game.creature.kamikaze.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.kamikaze.range and distance > 20 then
                -- Set attack cooldown
                creature.currentCooldown = game.creature.kamikaze.cooldown
                creature.attacking = nearestEnemy

                -- Damage the nearest enemy
                game.creature.default.damage(nearestEnemy, creature.meleeDamage)

                -- Deal explosion damage to all nearby enemies
                for _, otherCreature in ipairs(creatureStore) do
                    local explosionDistance = math.sqrt((otherCreature.x - nearestEnemy.x)^2 + (otherCreature.y - nearestEnemy.y)^2)

                    if explosionDistance < game.creature.kamikaze.bombRange and creature.player ~= otherCreature.player then
                        local explosionDamage = creature.rangedDamage * (1 - explosionDistance / game.creature.kamikaze.bombRange)
                        game.creature.default.damage(otherCreature, explosionDamage)
                    end
                end

                -- Self-destruct after the attack
                game.creature.default.damage(creature, creature.health) -- Inflict full health damage to destroy kamikaze creature
            end
        end
    end
end

function game.creature.kamikaze.draw(creature)

    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.2, 0.2, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(kamikazeImage, transform)

end