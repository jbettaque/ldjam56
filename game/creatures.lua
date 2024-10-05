game.creatures = {}
game.creature = {}
require("game/creature/default")
require("game/creature/attacker")
require("game/creature/ranger")



local creatureStore = {}



function game.creatures.load()
    --for i = 1, 1000 do
    --    local randomx = math.random(0, 800)
    --    local randomy = math.random(0, 600)
    --    local randomPlayer = math.random(1, 2)
    --    game.creatures.spawnCreature("attacker", randomx, randomy, randomPlayer)
    --end
end

function game.creatures.update(dt)
    for i, creature in ipairs(creatureStore) do
        game.creature.default.update(dt, creature, creatureStore)
    end


    for i, v in ipairs(game.towerPlacement.towers) do
        if v.spawningCooldown == 0 then
            if v.player == 1 then
                if v.type == "rectangle" then
                    game.creatures.spawnCreature("attacker", v.x, v.y, 1, v.powerLv)
                elseif v.type =="circle" then
                    game.creatures.spawnCreature("ranger", v.x, v.y, 1, v.powerLv)
                end
            else
                game.creatures.spawnCreature("attacker", 800, v.y, 2, v.powerLv)
            end
            v.spawningCooldown = 0.8
        end
    end

    -- Spawn tower creatures
    if love.timer.getTime() % 1 < 0.03 then


        --spawn test wave enemies
        for i = 1, 5 do
            game.creatures.spawnCreature("attacker", 800, 300, 2, 1)
        end
    end


end

function game.creatures.draw()
    for i, creature in ipairs(creatureStore) do
        game.creature.default.draw(creature)
    end
end

function game.creatures.spawnCreature(type, x, y, player, powerLv)
    local meleeDamage = game.creature[type].meleeDamage * powerLv
    local rangedDamage = game.creature[type].rangedDamage * powerLv
    local newCreature = {
        x = x,
        y = y,
        type = type,
        player = player,
        health = game.creature[type].health,
        meleeDamage = meleeDamage,
        rangedDamage = rangedDamage,
        speed = game.creature[type].speed,
        currentCooldown = 0,

    }
    table.insert(creatureStore, newCreature)
end

