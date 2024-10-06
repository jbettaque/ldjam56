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

                creature.currentCooldown = game.creature.kamikaze.cooldown
                creature.attacking = nearestEnemy
                nearestEnemy.health = nearestEnemy.health - creature.rangedDamage
                checkHealth(nearestEnemy, creatureStore, creature)
                local kamikazeIndex = 0
                for i, otherCreature in ipairs(creatureStore) do
                    local distance = math.sqrt((otherCreature.x - nearestEnemy.x)^2 + (otherCreature.y - nearestEnemy.y)^2)

                    if distance < game.creature.kamikaze.bombRange and creature.player ~= otherCreature.player then
                        local damage = creature.rangedDamage * (1 - distance / game.creature.kamikaze.bombRange)
                        otherCreature.health = otherCreature.health - damage
                        checkHealth(otherCreature, creatureStore, creature)
                    end
                end
                for i, otherCreature in ipairs(creatureStore) do
                    if otherCreature == creature then
                        table.remove(creatureStore, i)
                        break
                    end
                end

            end
        end
    end
end
function checkHealth(creature, creatureStore, parentCreature)
    if not creature then
        return
    end
    if creature.health <= 0 then
        for i, otherCreature in ipairs(creatureStore) do
            if otherCreature == creature then
                table.remove(creatureStore, i)
                if creature.player == 1 then
                    game.manager.player2.money = game.manager.player2.money + 5
                else
                    game.manager.player1.money = game.manager.player1.money + 5
                end
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