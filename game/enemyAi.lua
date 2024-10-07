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

-- **Timer Variables**
local timeSinceLastUpdate = 0
local updateInterval = 1 -- Set the interval to 5 seconds

-- **Table to Store AI's Towers**
local aiTowers = {}
local availableTowers = {}
local mineCount = 0
function game.enemyAi.load()
    print("enemyAi loaded")
    -- No need to repopulate towerOptions here unless necessary
    mineCount = 0
    availableTowers = {}
    aiTowers = {}
end

function game.enemyAi.update(dt)
    timeSinceLastUpdate = timeSinceLastUpdate + dt

    if timeSinceLastUpdate >= updateInterval then
        -- Reset the timer
        timeSinceLastUpdate = timeSinceLastUpdate - updateInterval

        -- **AI Actions Start Here**

        -- Ensure towerOptions is not empty
        if #towerOptions == 0 then
            print("No towers available in towerOptions.")
            return
        end

        -- **Count the Number of Mines the AI Has Bought**
        local mineCount = 0
        for _, tower in ipairs(aiTowers) do
            print("tower in aiTowers:", tower.type)
            if string.lower(tower.type) == "mine" then
                mineCount = mineCount + 1
            end
        end

        -- **Create a Filtered List of Towers**
        availableTowers = {}
        for _, towerOption in ipairs(towerOptions) do
            if mineCount < 5 or string.lower(towerOption.type) ~= "mine" then
                table.insert(availableTowers, towerOption)
            else
                print("Skip since to many mines:", towerOption.type)
            end
        end

        -- Check if there are any towers available to buy
        if #availableTowers == 0 then
            print("No towers available for purchase.")
            return
        end

        -- Choose a random tower from the filtered list
        local selectedTower = availableTowers[math.random(#availableTowers)]
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
                    randomx, randomy, selectedTower.type, 2
            )
            print("enemyAi bought a " .. selectedTower.type .. " spawning: " .. randomType .. " tower at " .. randomx .. ", " .. randomy)

            tower.spawnType = randomType
            print("Tower spawning:", tower.spawnType)
            -- **Add the Tower to aiTowers**
            table.insert(aiTowers, {type = selectedTower.type, instance = tower})
        else
            print("Not enough money to buy tower:", selectedTower.type)
        end

        -- **AI Actions End Here**
    end
end

function game.enemyAi.draw()
    -- Drawing code if necessary
end
