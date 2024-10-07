game.tMenu = {}
local menuTileX = 80
local menuTileY = 60
local gap = 5
local activeMenus = {}
local hoveredTile = nil
local selectedTower = nil

towerSounds = { aoe = nil, infantry = nil, mage = nil, range = nil}
towerPlacementSound = nil

require("game/utils")
-- Menu configurations
menuTypes = {
    tower = {
        items = game.towerPlacement.towerTypes,
        color = { 0, 0, 1 },
        onHover = function(itemIndex)

            game.towerPlacement.changeType(game.towerPlacement.towerTypes[itemIndex])
        end,
        onSelect = function(x, y, itemIndex)
            local towerType = game.towerPlacement.towerTypes[itemIndex]
            print(towerType)
            if game.manager.isEnoughMoney(towerConfig[towerType].cost, 1) then
                game.towerPlacement.addTower(game.towerPlacement.createTower(game.towerPlacement.currentPlacingTower.x, game.towerPlacement.currentPlacingTower.y, towerType, 1))
                game.towerPlacement.currentPlacingTower = nil
                game.manager.subtractMoney(towerConfig[towerType].cost, 1)
                game.tMenu.playTowerPlacementSound(towerType)
            else
                game.towerPlacement.currentPlacingTower = nil
            end


            game.tMenu.playTowerPlacementSound(towerType)

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
        items = { "Damage", "Speed", "Health", "Destroy" },
        color = { 0, 1, 0 },
        onHover = function(itemIndex)
        end,
        onSelect = function(x, y, itemIndex)
            local cost = calculateUpgradeCost()

            if itemIndex == 1 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.powerLv = selectedTower.powerLv + 1
                    game.manager.subtractMoney(cost, 1)
                    print("upgraded to Power Lv: ".. selectedTower.powerLv)
                end
            elseif itemIndex == 2 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.speedLv = selectedTower.speedLv + 1
                    game.manager.subtractMoney(cost, 1)
                    print("upgraded to Speed Lv: "..selectedTower.speedLv)
                end
            elseif itemIndex == 3 then
                if game.manager.isEnoughMoney(cost, 1) then
                    selectedTower.healthLv = selectedTower.healthLv + 1
                    game.manager.subtractMoney(cost, 1)
                    print("upgraded to health Lv: "..selectedTower.healthLv)
                end
            elseif itemIndex == 4 then
                for i, tower in ipairs(game.towerPlacement.towers) do
                    if tower == selectedTower then
                        table.remove(game.towerPlacement.towers, i)
                        break
                    end
                end

            end
            return selectedTower
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
            love.graphics.printf(
                    "Cost: " .. calculateUpgradeCost(),
                    x,
                    y + height / 2 - 20,
                    width,
                    "center"
            )
        end
    },
    unitSelect = {
        items = { "Carl", "Dog", "Horde", "Skelleton" },
        color = { 1, 0, 0 },
        onHover = function(itemIndex)
        end,
        onSelect = function(x, y, itemIndex)
            local unitType = menuTypes.unitSelect.items[itemIndex]
            selectedTower.spawnType = unitType
        end,
        beforeOpen = function(x, y)
            menuTypes.unitSelect.items = selectedTower.possibleSpawnTypes

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
    }


}
function calculateUpgradeCost()
    local totalLevel = selectedTower.powerLv + selectedTower.speedLv + selectedTower.healthLv
    return math.floor(towerConfig[selectedTower.type].cost * (totalLevel - 2) / 3)
end

function game.tMenu.load()
    towerSounds.aoe = love.audio.newSource("game/SFX/Audio/Tower Sounds/AOE Tower Ambiente_mixdown.mp3", "static")
    towerSounds.infantry = love.audio.newSource("game/SFX/Audio/Tower Sounds/Infantrie Tower Ambiente_mixdown.mp3", "static")
    towerSounds.mage = love.audio.newSource("game/SFX/Audio/Tower Sounds/Magic Tower Ambiente_mixdown.mp3", "static")
    towerSounds.range = love.audio.newSource("game/SFX/Audio/Tower Sounds/Range Tower Ambiente.mp3", "static")

    towerPlacementSound = love.audio.newSource("game/SFX/Audio/Tower Sounds/Tower Placement.mp3", "static")

end


local function createMenu(menuType, x, y)
    local config = menuTypes[menuType]
    if not config then
        return
    end

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

    if menuType == "upgrade" or menuType == "unitSelect" then
        game.tMenu.playTowerSound()
    end
end

function game.tMenu.draw()
    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then
            return
        end

        font = love.graphics.newFont(12)
        love.graphics.setFont(font)
        -- Draw background
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", menu.x, menu.y, menu.width, menu.height)

        -- Draw items
        for i, item in ipairs(config.items) do
            local itemX = menu.x + ((i - 1) * menuTileX) + gap * i
            local itemY = menu.y + gap

            -- Draw tile background
            --print(item)
            if menu.type == "tower" and not game.manager.isEnoughMoney(towerConfig[item].cost, 1) then
                love.graphics.setColor(config.color[1] + 0.3, config.color[2] + 0.3, config.color[3] + 0.3)
            elseif menu.type == "upgrade" and not game.manager.isEnoughMoney(calculateUpgradeCost(), 1) then
                love.graphics.setColor(config.color[1] + 0.3, config.color[2] + 0.3, config.color[3] + 0.3)

            elseif hoveredTile == i then
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

        -- Draw white border around selectedTower
        if selectedTower then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", selectedTower.x - 30, selectedTower.y - 30, 60, 60)
        end
    end
end
game.keySequence = {}
game.cheats = { "irwinner", "wimpywimpywimpy", "ninjalui", "berlinwall", "iwantyoutoticklemyfoot" }
game.activeCheats = {}
function game.tMenu.keypressed(key)
    -- Insert the pressed key into the key sequence
    table.insert(game.keySequence, key)

    -- Ensure the key sequence doesn't exceed 20 keys
    if #game.keySequence > 20 then
        table.remove(game.keySequence, 1)
    end

    -- Check if any cheat code has been entered
    game.checkForSeq()
end

function game.checkForSeq()
    -- Concatenate the key sequence into a string for comparison
    local currentSequence = table.concat(game.keySequence)

    -- Loop through all cheat codes and check if they exist in the current key sequence
    for _, cheatCode in ipairs(game.cheats) do
        if currentSequence:find(cheatCode) then
            -- If the cheat code is already active, remove it (toggle off)
            if game.activeCheats[cheatCode] then
                game.activeCheats[cheatCode] = nil
                game.triggerCheat(cheatCode, false)
                print("Cheat deactivated: " .. cheatCode)
            else
                -- If the cheat code is not active, activate it (toggle on)
                game.activeCheats[cheatCode] = true
                game.triggerCheat(cheatCode, true)
                print("Cheat activated: " .. cheatCode)
            end
            game.keySequence = {}
        end
    end
end

function game.triggerCheat(cheatCode, isActivated)
    if cheatCode == "irwinner" then
        if isActivated then
            for i = #game.towerPlacement.towers, 1, -1 do
                if game.towerPlacement.towers[i].player == 2 then
                    table.remove(game.towerPlacement.towers, i)
                end
            end
            game.activeCheats[cheatCode] = nil
        end
    end
    if cheatCode == "wimpywimpywimpy" then
        if isActivated then
            for i = #game.towerPlacement.towers, 1, -1 do
                if game.towerPlacement.towers[i].player == 1 then
                    table.remove(game.towerPlacement.towers, i)
                end
            end
            game.activeCheats[cheatCode] = nil
        end
    end
    if cheatCode == "ninjalui" then
        if isActivated then
            game.manager.player1.money = 100000
            print("gave player 100000 money")
            game.activeCheats[cheatCode] = nil
        end
    end
    if cheatCode == "berlinwall" then
        if isActivated then
            game.map.obstacles = {}
            print("gave player 100000 money")
            game.activeCheats[cheatCode] = nil
        end
    end
end
function game.tMenu.mousepressed(x, y, button)
    local clickedMenu = false

    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then
            goto continue
        end

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
        else
            activeMenus = {}
            selectedTower = nil
            game.towerPlacement.currentPlacingTower = nil
        end
        :: continue ::
    end

    if not clickedMenu then
        if x >= 0 and x <= love.graphics.getWidth() / 6 and
                y >= 0 and y <= love.graphics.getHeight() then
            for i, v in ipairs(game.towerPlacement.towers) do
                local distance = game.utils.distance(x, y, v.x, v.y)
                if distance < 60 then
                    if v.laserTurret ~= true and v.spawnType ~= "none" then
                        selectedTower = v
                        if (button == 2) then
                            game.tMenu.openMenu("upgrade", x, y)
                        else
                            game.tMenu.openMenu("unitSelect", x, y)
                        end

                    end
                    return
                end

            end
            game.tMenu.openMenu("tower", x, y)
        end
    end
end

function game.tMenu.update(dt)

    local mx, my = love.mouse.getPosition()
    hoveredTile = nil

    for _, menu in ipairs(activeMenus) do
        local config = menuTypes[menu.type]
        if not config then
            goto continue
        end

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
        :: continue ::
    end
end

function game.tMenu.playTowerSound()
    towerSounds[selectedTower.type]:play()
end

function game.tMenu.playTowerPlacementSound(towerType)
    towerPlacementSound:play()
    if towerSounds[towerType] then
        towerSounds[towerType]:play()
    end
end