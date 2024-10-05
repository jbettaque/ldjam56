game.map = {}

function game.map.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth()/6, love.graphics.getHeight())

    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", love.graphics.getWidth() - love.graphics.getWidth()/6, 0, love.graphics.getWidth()/4, love.graphics.getHeight())
end

