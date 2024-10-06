game.creature.carl = {}

game.creature.carl.health = 100
game.creature.carl.meleeDamage = 5
game.creature.carl.rangedDamage = 0
game.creature.carl.speed = 3
game.creature.carl.cooldown = 0.3
game.creature.carl.range = 1

local carlImage = love.graphics.newImage("game/Sprites/Carl.png")

game.creature.carl.draw = function(creature)
    love.graphics.setColor(1, 1, 1)
    if creature.damaged and creature.damaged > 0 then
        love.graphics.setColor(1, 0, 0)
    end
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.25, 0.25, 32, 32)
    if (creature.player == 1) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(carlImage, transform)

end