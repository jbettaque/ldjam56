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

    -- Spawn tower creatures
    if love.timer.getTime() % 1 < 0.03 then
        for i, v in ipairs(game.towerPlacement.towers) do
            if v.player == 1 then
                if v.type == "rectangle" then
                    game.creatures.spawnCreature("attacker", v.x, v.y, 1)
                elseif v.type =="circle" then
                    game.creatures.spawnCreature("ranger", v.x, v.y, 1)
                end

            else
                game.creatures.spawnCreature("attacker", 800, v.y, 2)
            end
        end

        --spawn test wave enemies
        for i = 1, 5 do
            game.creatures.spawnCreature("attacker", 800, 300, 2)
        end
    end


end

function game.creatures.draw()
    for i, creature in ipairs(creatureStore) do
        if creature.player == 1 then
            love.graphics.setColor(0, 0, 1)
        else
            love.graphics.setColor(1, 0, 0)
        end
        if creature.type == "attacker" then
            love.graphics.circle("fill", creature.x, creature.y, 10, 5)
        end
        if creature.type == "ranger" then
            love.graphics.circle("fill", creature.x, creature.y, 10, 10)
        end

        if (creature.health < game.creature[creature.type].health) then
            local healthbarColor = creature.health / game.creature[creature.type].health
            love.graphics.setColor(0.5, healthbarColor, 0)
            love.graphics.rectangle("fill", creature.x - 10, creature.y - 15, creature.health / game.creature[creature.type].health * 20, 5)
        end
    end
end

function game.creatures.spawnCreature(type, x, y, player)
    local newCreature = {
        x = x,
        y = y,
        type = type,
        player = player,
        health = game.creature[type].health,
        meleeDamage = game.creature[type].meleeDamage,
        rangedDamage = game.creature[type].rangedDamage,
        speed = game.creature[type].speed
    }
    table.insert(creatureStore, newCreature)
end

