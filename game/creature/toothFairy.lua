game.creature.toothFairy = {}

game.creature.toothFairy.health = 200
game.creature.toothFairy.meleeDamage = 3
game.creature.toothFairy.rangedDamage = 0
game.creature.toothFairy.speed = 2
game.creature.toothFairy.cooldown = 0.3
game.creature.toothFairy.range = 1

local toothFairyImage = love.graphics.newImage("game/Sprites/Tooth_Fairy.png")

function game.creature.toothFairy.draw(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.2, 0.2, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(toothFairyImage, transform)

end
