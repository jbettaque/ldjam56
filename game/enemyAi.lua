game.enemyAi = {}
require("game.towerPlacement")

-- Get towerConfig from towerPlacement
local towerConfig = game.towerPlacement.getTowerConfig()

-- Check if towerConfig is loaded correctly
if not towerConfig then
    error("Failed to retrieve towerConfig from towerPlacement")
end

-- Populate towerOptions from towerConfig
local towerOptions = {}

print("towerConfig:", towerConfig)
print("Populating towerOptions...")

for towerType, towerData in pairs(towerConfig) do
    print("Loading tower:", towerType)
    local option = {
        type = towerType, -- Use towerType as the type
        cost = towerData.cost, -- Use 'cost' instead of 'price'
        possibleSpawnTypes = towerData.possibleSpawnTypes,
        spawnType = towerData.spawnType
    }
    table.insert(towerOptions, option)
end

print("Number of towers loaded into towerOptions:", #towerOptions)

function game.enemyAi.load()
    print("enemyAi loaded")
    -- No need to repopulate towerOptions here unless necessary
end

function game.enemyAi.update(dt)
    -- Ensure towerOptions is not empty
    if #towerOptions == 0 then
        print("No towers available in towerOptions.")
        return
    end

    -- Choose a random tower from the table
    local selectedTower = towerOptions[math.random(#towerOptions)]
    if not selectedTower then
        print("Failed to select a tower.")
        return
    end

    print("Selected Tower:", selectedTower.type, "Cost:", selectedTower.cost)

    -- Check liquidity using 'cost'
    if game.manager.isEnoughMoney(selectedTower.cost, 2) then
        game.manager.player2.money = game.manager.player2.money - selectedTower.cost

        -- Random coordinate in building area
        local randomx = math.random(
                love.graphics.getWidth() - love.graphics.getWidth() / 6,
                love.graphics.getWidth()
        )
        local randomy = math.random(0, love.graphics.getHeight())

        -- Initialize randomType
        local randomType = nil

        -- Set the spawn type if applicable
        if selectedTower.possibleSpawnTypes then
            randomType = selectedTower.possibleSpawnTypes[math.random(#selectedTower.possibleSpawnTypes)]
        else
            randomType = selectedTower.spawnType -- For towers like "mine"
        end

        -- Place the tower and get the instance
        local tower = game.towerPlacement.placeTowerForAi(
                randomx, randomy, selectedTower.type, 2, randomType
        )
        print("enemyAi bought a " .. selectedTower.type .. " tower at " .. randomx .. ", " .. randomy)
    else
        print("Not enough money to buy tower:", selectedTower.type)
    end
end

function game.enemyAi.draw()
    -- Drawing code if necessary
end
