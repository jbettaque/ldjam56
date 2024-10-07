game.creature.dog = {}

game.creature.dog.health = 70
game.creature.dog.meleeDamage = 4
game.creature.dog.rangedDamage = 0
game.creature.dog.speed = 3
game.creature.dog.cooldown = 0.3
game.creature.dog.range = 0

local dogImage = love.graphics.newImage("game/Sprites/Dog.png")

game.creature.dog.draw = function(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.25, 0.25, 32, 32)
    if (creature.player == 1) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(dogImage, transform)

end