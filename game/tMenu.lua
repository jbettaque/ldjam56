game.tMenu = {}
local menuTileX = 40
local menuTileY = 40
local gap = 5
local activeMenus = {}
local hoveredTile = nil
local selectedTower = nil
-- Menu configurations
local menuTypes = {
    tower = {
        items = game.towerPlacement.towerTypes,
        color = {0, 0, 1},
        onHover = function(itemIndex)
            game.towerPlacement.changeType(game.towerPlacement.towerTypes[itemIndex])
        end,
        onSelect = function(x, y, itemIndex)
            local towerType = game.towerPlacement.towerTypes[itemIndex]
            if game.manager.isEnoughMoney(towerConfig[towerType].cost, 1) then
                game.towerPlacement.addTower(game.towerPlacement.currentPlacingTower)
                game.towerPlacement.currentPlacingTower = nil
                game.manager.subtractMoney(towerConfig[towerType].cost, 1)
            else
                game.towerPlacement.currentPlacingTower = nil
            end

        end,
        beforeOpen = function(x, y)
            game.towerPlacement.placeTower(x, y, game.towerPlacement.towerTypes[1])
        end,
        drawItem = function(item, x, y, width, height)
            -- Draw tile name
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(
                    item,
                    x,
                    y + height / 2,
                    width,
                    "center"
            )
        end
    },


    upgrade = {
        items = {"Damage", "Speed", "Health", "Destroy"},
        color = {0, 1, 0},
        onHover = function(itemIndex)

        end,
        onSelect = function(x, y, itemIndex)
            local totalLevel = selectedTower.powerLv +  selectedTower.speedLv + selectedTower.healthLv
            local cost = 10 * totalLevel + 10
            if itemIndex == 1 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.powerLv = selectedTower.powerLv+1
                    game.manager.subtractMoney(cost, 1)
                end
            elseif itemIndex == 2 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.speedLv = selectedTower.speedLv+1
                    game.manager.subtractMoney(cost, 1)
                end
            elseif itemIndex == 3 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.healthLv = selectedTower.healthLv + 1
                    game.manager.subtractMoney(cost, 1)
                end
            elseif itemIndex == 4 then
                table.remove(game.towerPlacement.towers, selectedTower.id)
            end
        end,
        drawItem = function(item, x, y, width, height)
            -- Custom drawing for upgrade menu items
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(
                    item,
                    x,
                    y + height / 2,
                    width,
                    "center"
            )
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                    "Cost: " .. 10 * (selectedTower.powerLv + selectedTower.speedLv + selectedTower.healthLv) + 10,
                    x,
                    y + height / 2 + 20,
                    width,
                    "center"
            )
        end
    }
    -- Add more menu types here, for example:


}

local function createMenu(menuType, x, y)
    local config = menuTypes[menuType]
    if not config then return end

    local menuWidth = (menuTileX * #config.items) + (gap * (#config.items + 1))
    local screenWidth = love.graphics.getWidth()

    -- Adjust x position if too close to right edge
    if x + menuWidth > screenWidth then
        x = x - menuWidth
    end

    return {
        type = menuType,
        x = x,
        y = y,
        width = menuWidth,
        height = menuTileY + gap * 2
    }
end

function game.tMenu.openMenu(menuType, x, y)
    -- Clear existing menus
    activeMenus = {}

    local config = menuTypes[menuType]
    if config and config.beforeOpen then
        config.beforeOpen(x, y)
    end

    local newMenu = createMenu(menuType, x, y)
    if newMenu then
        table.insert(activeMenus, newMenu)
    end
end

function game.tMenu.draw()
    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then return end

        -- Draw background
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", menu.x, menu.y, menu.width, menu.height)

        -- Draw items
        for i, item in ipairs(config.items) do
            local itemX = menu.x + ((i - 1) * menuTileX) + gap * i
            local itemY = menu.y + gap

            -- Draw tile background
            if hoveredTile == i then
                love.graphics.setColor(config.color[1] + 0.3, config.color[2] + 0.3, config.color[3] + 0.3)
            else
                love.graphics.setColor(config.color)
            end
            love.graphics.rectangle("fill", itemX, itemY, menuTileX, menuTileY)

            -- Draw item content
            if config.drawItem then
                config.drawItem(item, itemX, itemY, menuTileX, menuTileY)
            end
        end
    end
end

function game.tMenu.mousepressed(x, y, button, isTouch)
    local clickedMenu = false
    for i, tower in ipairs(game.towerPlacement.towers) do
        if isClickOnTower(x, y, tower) then
            print("Clicked on tower " .. tower.id)
            game.tMenu.openMenu("upgrade", x, y)
            selectedTower = tower
            return
        end
    end
    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then goto continue end

        if x >= menu.x and x <= menu.x + menu.width and
                y >= menu.y and y <= menu.y + menu.height then
            clickedMenu = true

            -- Check if clicked on specific item
            for i = 1, #config.items do
                local itemX = menu.x + ((i - 1) * menuTileX) + gap * i
                local itemY = menu.y + gap

                if x >= itemX and x <= itemX + menuTileX and
                        y >= itemY and y <= itemY + menuTileY then
                    if config.onSelect then
                        config.onSelect(x, y, i)
                    end
                    activeMenus = {}
                    return
                end
            end
        end
        ::continue::
    end

    if not clickedMenu then
        if x >= 0 and x <= love.graphics.getWidth()/6 and
                y >= 0 and y <= love.graphics.getHeight() then
            game.tMenu.openMenu("tower", x, y)
        end
    end
end

function game.tMenu.update(dt)
    local mx, my = love.mouse.getPosition()
    hoveredTile = nil

    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then goto continue end

        if mx >= menu.x and mx <= menu.x + menu.width and
                my >= menu.y and my <= menu.y + menu.height then

            for i = 1, #config.items do
                local itemX = menu.x + ((i - 1) * menuTileX) + gap * i
                local itemY = menu.y + gap

                if mx >= itemX and mx <= itemX + menuTileX and
                        my >= itemY and my <= itemY + menuTileY then
                    hoveredTile = i
                    if config.onHover then
                        config.onHover(i)
                    end
                    break
                end
            end
        end
        ::continue::
    end
end