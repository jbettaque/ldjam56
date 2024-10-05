game.tMenu = {}
local menuTileX = 40
local menuTileY = 40
local gap = 5
rectangles = {}
color = {0, 0, 1}
local hoveredTile = nil

function game.tMenu.draw()
    for _, rect in ipairs(rectangles) do
        drawMenu(rect.x, rect.y, color, 3)
    end
end

function game.tMenu.mousepressed(x, y, button, isTouch)
    -- Check if click is inside any existing menu
    local clickedInside = false
    for i, rect in ipairs(rectangles) do
        local menuWidth = (menuTileX * 7) + (gap * 8)
        local menuHeight = menuTileY + gap * 2

        if x >= rect.x and x <= rect.x + menuWidth and
                y >= rect.y and y <= rect.y + menuHeight then
            clickedInside = true
            break
        end
    end

    -- If clicked outside all menus, clear them
    if not clickedInside then
        -- Create new menu only if no menus exist
        rectangles = {}
        local screenWidth = love.graphics.getWidth()
        local menuWidth = (menuTileX * 7) + (gap * 8)

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
        local menuWidth = (menuTileX * 7) + (gap * 8)
        local menuHeight = menuTileY + gap * 2

        -- Check if mouse is inside menu
        if mx >= rect.x and mx <= rect.x + menuWidth and
                my >= rect.y and my <= rect.y + menuHeight then
            -- Calculate which tile is being hovered
            for i = 1, 7 do
                local tileX = rect.x + ((i - 1) * menuTileX) + gap * i
                local tileY = rect.y + gap

                if mx >= tileX and mx <= tileX + menuTileX and
                        my >= tileY and my <= tileY + menuTileY then
                    hoveredTile = i
                    break
                end
            end
        end
    end
end

function drawMenu(mouseX, mouseY, color, tiles)
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
    end
end