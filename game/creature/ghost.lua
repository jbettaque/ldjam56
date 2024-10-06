game.creature.ghost = {}

game.creature.ghost.health = 0
game.creature.ghost.meleeDamage = 1
game.creature.ghost.rangedDamage = 0
game.creature.ghost.speed = 1
game.creature.ghost.cooldown = 0.3
game.creature.ghost.range = 1

local ghostImage = love.graphics.newImage("game/Sprites/Ghost.png")


function game.creature.ghost.draw(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.23, 0.23, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(ghostImage, transform)

end
