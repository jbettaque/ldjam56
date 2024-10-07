game.creature.acid = {}

game.creature.acid.health = 20
game.creature.acid.meleeDamage = 0
game.creature.acid.rangedDamage = 0.01
game.creature.acid.speed = 1.3
game.creature.acid.cooldown = 2.5
game.creature.acid.range = 30
game.creature.acid.bombRange = 100
game.creature.acid.backOffDistance = 1
game.creature.acid.aoeTimer = 5
local acidImage = love.graphics.newImage("game/Sprites/Acid_Tick.png")

function game.creature.acid.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.acid.range and distance > 20 then
                game.map.addAreaEffect(creature.x, creature.y, 70, game.creature.acid.areaEffect, game.creature.acid.aoeTimer, {0.2, 1, 0.2, 0.5}, creature.player)
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

function game.creature.acid.areaEffect(creature, owner)
    if creature.player ~= owner then
        game.creature.default.damage(creature, game.creature.acid.rangedDamage)
    end
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


        love.graphics.setColor(1, 1, 1)
        if creature.damaged and creature.damaged > 0 then
            love.graphics.setColor(1, 0, 0)
        end
        local transform = love.math.newTransform(creature.x, creature.y, 0, 0.20, 0.20, 32, 32)
        if (creature.player == 1) then
            transform:scale(1, 1)
        end

        love.graphics.draw(acidImage, transform)

end