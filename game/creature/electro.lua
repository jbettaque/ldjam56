game.creature.electro = {}

game.creature.electro.health = 200
game.creature.electro.meleeDamage = 0
game.creature.electro.rangedDamage = 0.01
game.creature.electro.speed = 0.2
game.creature.electro.cooldown = 0.5
game.creature.electro.range = 150
game.creature.electro.bombRange = 100
game.creature.electro.backOffDistance = 100
game.creature.electro.aoeTimer = 0.5

local electroImage = love.graphics.newImage("game/Sprites/Electro_Hedgehog.png")


function game.creature.electro.attack(dt, creature, creatureStore)
    if creature.currentCooldown == 0 then
        local nearestEnemy = game.creature.default.findNearestEnemy(creature, creatureStore)

        if nearestEnemy then
            local distance = math.sqrt((creature.x - nearestEnemy.x)^2 + (creature.y - nearestEnemy.y)^2)
            if distance < game.creature.electro.range then
                creature.currentCooldown = game.creature.electro.cooldown
                -- yellow aoe electricity effect
                game.map.addAreaEffect(creature.x, creature.y, 70, game.creature.electro.areaEffect, game.creature.electro.aoeTimer, {1, 1, 0, 0.5}, creature.player)
            end
        end
    end
end

function game.creature.electro.areaEffect(creature, owner)
    if creature.player ~= owner then
        game.creature.default.damage(creature, game.creature.electro.rangedDamage)
    end
end


function game.creature.electro.move(dt, creature, creatureStore)
    game.creature.egg.move(dt, creature, creatureStore)
end

function game.creature.electro.draw(creature)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(electroImage, creature.x, creature.y, 0, 0.2, 0.2, 32, 32)

    if creature.attacking then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(creature.x, creature.y, creature.attacking.x, creature.attacking.y)
        love.graphics.circle("line", creature.attacking.x, creature.attacking.y, game.creature.electro.bombRange)
    end



end