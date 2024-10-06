game.creature.kamikaze = {}

game.creature.kamikaze.health = 150
game.creature.kamikaze.meleeDamage = 0
game.creature.kamikaze.rangedDamage = 300
game.creature.kamikaze.speed = 1
game.creature.kamikaze.cooldown = 2.5
game.creature.kamikaze.range = 30
game.creature.kamikaze.bombRange = 200


function game.creature.kamikaze.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.kamikaze.range and distance > 20 then

                -- Setze den Angriffscooldown
                creature.currentCooldown = game.creature.kamikaze.cooldown
                creature.attacking = nearestEnemy

                -- Schaden beim nächsten Feind
                game.creature.default.damage(nearestEnemy, creature.meleeDamage)

                -- Explosionsradius: Schaden an allen Feinden in der Nähe
                for i, otherCreature in ipairs(creatureStore) do
                    local explosionDistance = math.sqrt((otherCreature.x - nearestEnemy.x)^2 + (otherCreature.y - nearestEnemy.y)^2)

                    if explosionDistance < game.creature.kamikaze.bombRange and creature.player ~= otherCreature.player then
                        local explosionDamage = creature.rangedDamage * (1 - explosionDistance / game.creature.kamikaze.bombRange)
                        game.creature.default.damage(otherCreature, explosionDamage)
                    end
                end

                -- Entferne die Kamikaze-Kreatur selbst nach dem Angriff
                game.creature.default.damage(creature, creature.health) -- Schaden gleich der gesamten Gesundheit der Kamikaze-Kreatur
            end
        end
    end
end

function game.creature.kamikaze.draw(creature)

    if creature.player == 1 then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("line", creature.x, creature.y, 10)

    if creature.attacking then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
        love.graphics.circle("line", creature.attacking.x, creature.attacking.y, game.creature.kamikaze.bombRange)
    end



end