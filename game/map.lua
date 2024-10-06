game.map = {}
game.map.obstacles = {}
game.map.playAreas = {}

game.map.laneCount = 3
game.map.editorMode = false

local LINE_THICKNESS = 5
local bgImage = love.graphics.newImage("game/Sprites/Map.png")

function game.map.createObstacle(x, y, width, height)
    local newObstacle = {
        x = x,
        y = y,
        width = width,
        height = height
    }
    table.insert(game.map.obstacles, newObstacle)
end

function createSeparatorLines(n, screenWidth, screenHeight, playAreaWidth)
    local playableWidth = screenWidth - (playAreaWidth * 2)
    local centerX = screenWidth / 2
    local lineWidth = playableWidth

    for i = 1, n do
        local yPosition = (i * (screenHeight / (n + 1)))

        game.map.createObstacle(
                centerX - (lineWidth / 2),
                yPosition,
                lineWidth,
                LINE_THICKNESS
        )
    end
end

function initializePlayArea(screenWidth, screenHeight, playAreaWidth)
    table.insert(game.map.playAreas, {
        x = 0,
        y = 0,
        width = playAreaWidth,
        height = screenHeight,
        color = {0, 1, 0, 0.5},
        player = 1
    })
    table.insert(game.map.playAreas, {
        x = screenWidth - playAreaWidth,
        y = 0,
        width = playAreaWidth,
        height = screenHeight,
        color = {1, 0, 0, 0.5},
        player = 2
    })
end
-- add obstacle get height and width with second click
local firstClick = {}
function game.map.mousepressed(x, y, button)
    if button == 1 and game.map.editorMode then
        if firstClick.x then
            -- Calculate width and height using absolute values
            local width = math.abs(x - firstClick.x)
            local height = math.abs(y - firstClick.y)

            -- Determine the starting x and y positions
            local startX = math.min(firstClick.x, x)
            local startY = math.min(firstClick.y, y)

            game.map.createObstacle(startX, startY, width, height)
            firstClick = {}
        else
            firstClick.x = x
            firstClick.y = y
        end
    end
end
function game.map.update(dt)
end
function game.map.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local playAreaWidth = screenWidth/4

    initializePlayArea(screenWidth, screenHeight, playAreaWidth)
    createSeparatorLines(game.map.laneCount - 1, screenWidth, screenHeight, playAreaWidth)
end

function game.map.draw()


    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bgImage, 0, 0, 0, 0.7, 0.7)
    --display if in editorMode
    if game.map.editorMode then
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
    --drawPlayAreas()
    drawObstacles()
end

function drawPlayAreas()
    for i, area in ipairs(game.map.playAreas) do
        love.graphics.setColor(area.color)
        love.graphics.rectangle("fill", area.x, area.y, area.width, area.height)
    end
end

function drawObstacles()
    for i, section in ipairs(game.map.obstacles) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", section.x, section.y, section.width, section.height)
    end
end