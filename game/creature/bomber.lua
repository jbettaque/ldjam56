game.creature.bomber = {}

game.creature.bomber.health = 20
game.creature.bomber.meleeDamage = 0
game.creature.bomber.rangedDamage = 2
game.creature.bomber.speed = 0.3
game.creature.bomber.cooldown = 0.9
game.creature.bomber.range = 150
game.creature.bomber.bombRange = 100
game.creature.bomber.backOffDistance = 100


function game.creature.bomber.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        print("Bomber attacking")
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)
        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.bomber.range and distance > 20 then
                print("Bomber attacking and in range")
                creature.currentCooldown = game.creature.bomber.cooldown
                creature.attacking = nearestEnemy
                nearestEnemy.health = nearestEnemy.health - creature.rangedDamage
                checkHealth(nearestEnemy, creatureStore)
                for i, otherCreature in ipairs(creatureStore) do
                    local distance = math.sqrt((otherCreature.x - nearestEnemy.x)^2 + (otherCreature.y - nearestEnemy.y)^2)

                    if distance < game.creature.bomber.bombRange and creature.player ~= otherCreature.player then
                        local damage = creature.rangedDamage * (1 - distance / game.creature.bomber.bombRange)
                        otherCreature.health = otherCreature.health - damage
                        checkHealth(otherCreature, creatureStore)
                    end

                end


            end
        end

    end

end
function checkHealth(creature, creatureStore)
    if not creature then
        return
    end
    if creature.health <= 0 then
        for i, otherCreature in ipairs(creatureStore) do
            if otherCreature == creature then
                table.remove(creatureStore, i)
                break
            end
        end

        for i, tower in ipairs(game.towerPlacement.towers) do
            if tower == creature then
                print("Tower destroyed")
                table.remove(game.towerPlacement.towers, i)
                break
            end
        end
    end
end
function game.creature.bomber.move(dt, creature, creatureStore)
    game.creature.ranger.move(dt, creature, creatureStore)
end

function game.creature.bomber.draw(creature)

    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("line", creature.x, creature.y, 10)

    if creature.attacking then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
        love.graphics.circle("line", creature.attacking.x, creature.attacking.y, game.creature.bomber.bombRange)
    end



end