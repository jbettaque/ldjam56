game.creature.acid = {}

game.creature.acid.health = 20
game.creature.acid.meleeDamage = 0
game.creature.acid.rangedDamage = 30
game.creature.acid.speed = 0.3
game.creature.acid.cooldown = 2.5
game.creature.acid.range = 150
game.creature.acid.bombRange = 100
game.creature.acid.backOffDistance = 100


function game.creature.acid.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.acid.range and distance > 20 then
                game.map.addAreaEffect(creature.x, creature.y, 70, game.creature.acid.areaEffect, 30, {0.2, 1, 0.2, 0.5})
                -- remove creature from creatureStore
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

function game.creature.acid.areaEffect(creature)
    game.creature.default.damage(creature, game.creature.acid.rangedDamage)

    print("Acid attack")
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
function game.creature.acid.move(dt, creature, creatureStore)
    game.creature.egg.move(dt, creature, creatureStore)
end

function game.creature.acid.draw(creature)

    if creature.player == 1 then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("line", creature.x, creature.y, 10)

    if creature.attacking then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
        love.graphics.circle("line", creature.attacking.x, creature.attacking.y, game.creature.acid.bombRange)
    end



end