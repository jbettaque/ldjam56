game.creature.zombie = {}

game.creature.zombie.health = 250
game.creature.zombie.meleeDamage = 2
game.creature.zombie.rangedDamage = 0
game.creature.zombie.speed = 2
game.creature.zombie.cooldown = 0.3
game.creature.zombie.range = 1

local zombieImage = love.graphics.newImage("game/Sprites/Zombie.png")

game.creature.zombie.draw = function(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.2, 0.2, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(zombieImage, transform)

end