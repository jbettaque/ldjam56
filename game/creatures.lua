game.creatures = {}
game.creature = {}
require("game/creature/default")
require("game/creature/attacker")
require("game/creature/ranger")
require("game/creature/bomber")



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
            game.creatures.spawnCreature(v.spawnType, v.x, v.y, v.player, v.powerLv, v.healthLv)
            v.currentSpawnCooldown = v.spawningCooldown
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

