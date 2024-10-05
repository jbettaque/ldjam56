game.towerPlacement = {}

local towers = {}
local towerX, towerY = nil, nil


function game.towerPlacement.mousepressed(x, y, button, istouch, presses, towerType)
    local towerType = towerType
    if button == 1 then
        towerX, towerY = x, y
        table.insert(towers, {x = x, y = y, type = towerType})
    end
end

function game.towerPlacement.drawTowers()
    for i, tower in ipairs(towers) do
        if tower.type == "circle" then

            love.graphics.setColor(0, 1, 0)
            love.graphics.circle("fill", tower.x, tower.y, 20)

        elseif tower.type == "rectangle" then
            love.graphics.rectangle("fill", tower.x - 10, tower.y - 10, 40, 30)
        elseif tower.type == "image" then
            if tower.image then
                love.graphics.draw(tower.image, tower.x, tower.y)

            end
        end
    end
end