game.towerPlacement = {}

game.towerPlacement.towers = {}
game.towerPlacement.towerTypes = {"circle", "rectangle", "image"}
game.towerPlacement.currentPlacingTower = nil
local towerX, towerY = nil, nil
function game.towerPlacement.placeTower(x, y, towerType)
    local newTower = {
        id = #game.towerPlacement.towers + 1,
        x = x,
        y = y,
        type = towerType,
        player = 1,
        health = 10,
    }
    game.towerPlacement.currentPlacingTower = newTower
    return newTower
end
function game.towerPlacement.addTower(tower)
    towerX, towerY = x, y
    table.insert(game.towerPlacement.towers, tower)
end
function game.towerPlacement.mousepressed(x, y, button, istouch, presses, towerType)
    local towerType = towerType
    if button == 1 then

    end
end

function game.towerPlacement.drawTowers()

    for i, tower in ipairs(game.towerPlacement.towers) do
       drawTower(tower, "fill")
    end
    if game.towerPlacement.currentPlacingTower then
        drawTower(game.towerPlacement.currentPlacingTower, "line")
    end

end
function drawTower(tower, mode)
    if tower.type == "circle" then

        love.graphics.setColor(0, 1, 0)
        love.graphics.circle(mode, tower.x, tower.y, 20)

    elseif tower.type == "rectangle" then
        love.graphics.rectangle(mode, tower.x - 10, tower.y - 10, 40, 30)
    elseif tower.type == "image" then
        if tower.image then
            love.graphics.draw(tower.image, tower.x, tower.y)

        end
    end
end