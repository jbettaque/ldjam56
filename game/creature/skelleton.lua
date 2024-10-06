game.creature.skelleton = {}

game.creature.skelleton.health = 100
game.creature.skelleton.meleeDamage = 3
game.creature.skelleton.rangedDamage = 0
game.creature.skelleton.speed = 1
game.creature.skelleton.cooldown = 0.3
game.creature.skelleton.range = 1
local skelletonImage = love.graphics.newImage("game/Sprites/Skeleton.png")


function game.creature.skelleton.draw(creature)
    love.graphics.setColor(255, 255, 255)
    local transform = love.math.newTransform(creature.x, creature.y, 0, 0.2, 0.2, 32, 32)
    if (creature.player == 2) then
        transform:scale(-1, 1)
    end

    love.graphics.draw(skelletonImage, transform)

end
