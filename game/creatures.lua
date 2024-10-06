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

    if creature.isBoosted then
        creature.boostDuration = creature.boostDuration - dt
        if creature.boostDuration <= 0 then
            creature.speed = creature.originalSpeed
            creature.isBoosted = false
            print("Speed Boost ended for creature of player " .. creature.player)
        end
    end


    if creature.isHealthBoosted then
        creature.healthBoostDuration = creature.healthBoostDuration - dt
        if creature.healthBoostDuration <= 0 then

            creature.health = creature.originalHealth
            creature.isHealthBoosted = false
            print("Health Boost ended for creature of player " .. creature.player)
        end
    end
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

function game.creatures.applySpeedBoostToPlayer(playerId, speedMultiplier, duration)
    for i, creature in ipairs(creatureStore) do
        if creature.player == playerId then

            if not creature.isBoosted then
                creature.originalSpeed = creature.speed
                creature.speed = creature.speed * speedMultiplier
                creature.boostDuration = duration
                creature.isBoosted = true
                print("Speed Boost applied to creature of player " .. playerId)
            end
        end
    end
end

function game.creatures.applyHealthBoostToPlayer(playerId, healthMultiplier, duration)
    for i, creature in ipairs(creatureStore) do
        if creature.player == playerId then
            if not creature.isHealthBoosted then
                creature.originalHealth = creature.health
                creature.health = creature.health * healthMultiplier
                creature.healthBoostDuration = duration
                creature.isHealthBoosted = true
                print("Health Boost applied to creature of player " .. playerId)
            end
        end
    end
end

function game.creatures.spawnCreature(type, x, y, player, powerLv, healthLv)

    print("Spawning creature: " .. type .. " at " .. x .. ", " .. y .. " for player " .. player)
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


