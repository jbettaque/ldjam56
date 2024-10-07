game.creature.horde = {}

game.creature.horde.health = 10
game.creature.horde.meleeDamage = 1
game.creature.horde.rangedDamage = 2
game.creature.horde.speed = 2
game.creature.horde.cooldown = 0.3
game.creature.horde.range = 0

local hordeImage = love.graphics.newImage("game/Sprites/Zombie.png")

game.creature.horde.draw = function(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.1, 0.1, 0, 0)
    if (creature.player == 1) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(hordeImage, transform)

end