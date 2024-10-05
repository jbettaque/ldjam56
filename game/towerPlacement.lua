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

-- Helper function to check if a click is on a tower
function isClickOnTower(x, y, tower)
    if tower.type == "circle" then
        local distance = math.sqrt((x - tower.x)^2 + (y - tower.y)^2)
        return distance <= 20  -- Assuming radius is 20
    elseif tower.type == "rectangle" then
        return x >= tower.x - 10 and x <= tower.x + 30 and
                y >= tower.y - 10 and y <= tower.y + 20
    elseif tower.type == "image" then
        -- Assuming image dimensions, adjust as needed
        local imageWidth, imageHeight = 40, 40
        return x >= tower.x and x <= tower.x + imageWidth and
                y >= tower.y and y <= tower.y + imageHeight
    end
    return false
end