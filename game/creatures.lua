game.creatures = {}
game.creature = {}
require("game/creature/default")

--AREA OF EFFECT
require("game/creature/kamikaze")
require("game/creature/electro")
require("game/creature/acid")

--RANGED
require("game/creature/egg")
require("game/creature/tooth")
require("game/creature/flea")

--MELEE
require("game/creature/carl")
require("game/creature/dog")
require("game/creature/horde")
require("game/creature/skelleton")

--MAGIC
require("game/creature/ghost")



local creatureStore = {}

getCreatureStore = function()
    return creatureStore
end



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
        if v.currentSpawnCooldown == 0 then
            if v.spawnType ~= "none" then
                game.creatures.spawnCreature(v.spawnType, v.x, v.y, v.player, v.powerLv, v.healthLv)
                v.currentSpawnCooldown = v.spawningCooldown
            end
        end
    end
end

function game.creatures.draw()
    for i, creature in ipairs(creatureStore) do
        game.creature.default.draw(creature)
    end
end

function game.creatures.spawnCreature(type, x, y, player, powerLv, healthLv)

    local meleeDamage = game.creature[type].meleeDamage * powerLv
    local rangedDamage = game.creature[type].rangedDamage * powerLv
    local health = game.creature[type].health * healthLv
    local newCreature = {
        x = x,
        y = y,
        type = type,
        player = player,
        health = health,
        meleeDamage = meleeDamage,
        rangedDamage = rangedDamage,
        speed = game.creature[type].speed,
        currentCooldown = 0,

    }
    table.insert(creatureStore, newCreature)
end

