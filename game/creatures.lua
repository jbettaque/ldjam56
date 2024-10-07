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
require("game/creature/zombie")
require("game/creature/toothFairy")



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

    if creature.isDamageBoosted then
        creature.damageBoostDuration = creature.damageBoostDuration - dt
        if creature.damageBoostDuration <= 0 then
            -- Setze den ursprünglichen Schaden zurück
            creature.meleeDamage = creature.originalMeleeDamage
            creature.rangedDamage = creature.originalRangedDamage
            creature.isDamageBoosted = false
            print("Double Damage ended for creature of player " .. creature.player)
        end
    end

    game.creatures.updateProjectiles(dt)
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

function game.creatures.applyDoubleDamageToPlayer(playerId, damageMultiplier, duration)
    for i, creature in ipairs(creatureStore) do
        if creature.player == playerId then
            if not creature.isDamageBoosted then

                creature.originalMeleeDamage = creature.meleeDamage
                creature.originalRangedDamage = creature.rangedDamage


                creature.meleeDamage = creature.meleeDamage * damageMultiplier
                creature.rangedDamage = creature.rangedDamage * damageMultiplier

                creature.damageBoostDuration = duration
                creature.isDamageBoosted = true
                print("Double Damage applied to creature of player " .. playerId)
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
        stuckTime = 0,
        lastPosition = { x = x, y = y }

    }
    table.insert(creatureStore, newCreature)


    if type == "horde" then
        print("Spawning horde")
        for i = 1, 5 do
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
                stuckTime = 0,
                lastPosition = { x = x, y = y }

            }
            newCreature.x = x + math.random(-20, 20)
            newCreature.y = y + math.random(-20, 20)
            table.insert(creatureStore, newCreature)
        end
    end
end

function game.creatures.resetCreatureStore()
    creatureStore = {}
end

function game.creatures.getCreatureStore()
    return creatureStore
end

--local projectile = {
--    x = creature.x,
--    y = creature.y,
--    target = nearestEnemy,
--    speed = 200,
--    damage = creature.rangedDamage
--}

function game.creatures.updateProjectiles(dt)
    for i, creature in ipairs(creatureStore) do
        if creature.projectiles then
            for j, projectile in ipairs(creature.projectiles) do
                local distance = game.creature.default.getDistance(projectile.x, projectile.y, projectile.target.x, projectile.target.y)
                local angle = math.atan2(projectile.target.y - projectile.y, projectile.target.x - projectile.x)
                local speed = projectile.speed * dt
                local moveX = math.cos(angle) * speed
                local moveY = math.sin(angle) * speed
                projectile.x = projectile.x + moveX
                projectile.y = projectile.y + moveY

                if distance < 10 then
                    game.creature.default.damage(projectile.target, projectile.damage)
                    table.remove(creature.projectiles, j)

                end
            end

        end
    end
end