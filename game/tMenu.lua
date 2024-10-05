game.tMenu = {}
local menuTileX = 40
local menuTileY = 40
local gap = 5
rectangles = {}
local color = {0, 0, 1}
local hoveredTile = nil
local towerTypes = {"circle", "rectangle", "image"}
function game.tMenu.draw()
    for _, rect in ipairs(rectangles) do
        drawMenu(rect.x, rect.y, color)
    end
end

function game.tMenu.mousepressed(x, y, button, isTouch)
    -- Check if click is inside any existing menu
    local clickedInside = false
    for i, rect in ipairs(rectangles) do
        local menuWidth = (menuTileX * #towerTypes) + (gap * 8)
        local menuHeight = menuTileY + gap * 2

        if x >= rect.x and x <= rect.x + menuWidth and
                y >= rect.y and y <= rect.y + menuHeight then
            clickedInside = true

            -- Check if clicked inside a specific tile
            for tileIndex = 1, #towerTypes do
                local tileX = rect.x + ((tileIndex - 1) * menuTileX) + gap * tileIndex
                local tileY = rect.y + gap

                if x >= tileX and x <= tileX + menuTileX and
                        y >= tileY and y <= tileY + menuTileY then
                    -- Clicked inside this tile
                    print("Clicked on tile " .. tileIndex)

                    game.towerPlacement.addTower(game.towerPlacement.currentPlacingTower)
                    game.towerPlacement.currentPlacingTower = nil
                    rectangles = {}
                    -- You can add more actions here, like:
                    -- game.towerPlacement.placeTower(x, y, towerTypes[tileIndex])
                    return  -- Exit the function after handling the tile click
                end
            end


            break
        end
    end

    -- If clicked outside all menus, clear them
    if not clickedInside then
        -- Create new menu only if no menus exist
        game.towerPlacement.placeTower(x, y, towerTypes[1])
        rectangles = {}
        local screenWidth = love.graphics.getWidth()
        local menuWidth = (menuTileX * #towerTypes) + (gap * 8)

        -- Adjust x position if too close to right edge
        local newX = x
        if x + menuWidth > screenWidth then
            newX = x - menuWidth
        end

        local newRect = {
            x = newX,
            y = y
        }
        table.insert(rectangles, newRect)

    end
end

function game.tMenu.update(dt)
    -- Update hovered tile
    local mx, my = love.mouse.getPosition()
    hoveredTile = nil
    for _, rect in ipairs(rectangles) do
        local menuWidth = (menuTileX * #towerTypes) + (gap * 8)
        local menuHeight = menuTileY + gap * 2

        -- Check if mouse is inside menu
        if mx >= rect.x and mx <= rect.x + menuWidth and
                my >= rect.y and my <= rect.y + menuHeight then
            -- Calculate which tile is being hovered
            for i = 1, #towerTypes do
                local tileX = rect.x + ((i - 1) * menuTileX) + gap * i
                local tileY = rect.y + gap

                if mx >= tileX and mx <= tileX + menuTileX and
                        my >= tileY and my <= tileY + menuTileY then
                    game.towerPlacement.currentPlacingTower.type = towerTypes[i]
                    hoveredTile = i
                    break
                end
            end
        end
    end
end

function drawMenu(mouseX, mouseY, color)
    local tiles = #towerTypes
    local width = (menuTileX * tiles) + (gap * tiles + 5)
    local height = menuTileY + gap * 2

    -- Draw background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", mouseX, mouseY, width, height)

    -- Draw tiles
    for i = 1, tiles do
        if hoveredTile == i then
            -- Highlight hovered tile
            love.graphics.setColor(color[1] + 0.3, color[2] + 0.3, color[3] + 0.3)
        else
            love.graphics.setColor(color)
        end
        love.graphics.rectangle(
                "fill",
                mouseX + ((i - 1) * menuTileX) + gap * i,
                mouseY + gap,
                menuTileX,
                menuTileY
        )

        -- Draw tile name
        love.graphics.setColor(0, 0, 0) -- Set text color to black
        love.graphics.printf(
                towerTypes[i],
                mouseX + ((i - 1) * menuTileX) + gap * i,
                mouseY + gap + menuTileY / 2,
                menuTileX,
                "center"
        )
    end
end