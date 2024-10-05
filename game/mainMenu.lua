local mainMenu = {}

button_height = 64

local function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        now = false,
        last = false
    }
end

local buttons = {}
---@type table
local font = 0

function mainMenu.load(switchToGame)
    font = love.graphics.newFont(32)
    table.insert(buttons, newButton("Start Game", function()
        print("Starting game")
        switchToGame()
    end))
    table.insert(buttons, newButton("Settings", function()
        print("Opening Settings")
    end))
    table.insert(buttons, newButton("Exit Game", function()
        print("Exiting game")
        love.event.quit(0)
    end))
end

function mainMenu.update()
end

function mainMenu.draw()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local button_width = ww * (1 / 3)
    local buttonspace = 16
    local cursor_y = 0

    for i, button in ipairs(buttons) do
        button.last = button.now

        local buttonx = (ww * 0.5) - (button_width * 0.5)
        local buttony = (wh * 0.5) - (button_height * 0.5) + cursor_y

        local color = {0, 0.6, 1}
        local mx, my = love.mouse.getPosition()
        local hover = mx > buttonx and mx < buttonx + button_width and
                my > buttony and my < buttony + button_height

        if hover then
            color = {0, 1, 0}
        end

        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hover then
            button.fn()
        end

        love.graphics.setColor(unpack(color))

        love.graphics.rectangle("fill", buttonx, buttony, button_width, button_height)

        love.graphics.setColor(0, 0, 0)

        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text, font, (ww * 0.5) - textW * 0.5, buttony + textH * 0.5)

        cursor_y = cursor_y + (button_height + buttonspace)
    end
end

function mainMenu.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        local buttonx = (love.graphics.getWidth() * 0.5) - (love.graphics.getWidth() * (1/3) * 0.5)
        local buttony = (love.graphics.getHeight() * 0.5) - (button_height * 0.5) + (button_height + 16) * (_ - 1)

        if button == 1 and x > buttonx and x < buttonx + (love.graphics.getWidth() * (1/3)) and
                y > buttony and y < buttony + button_height then
            btn.fn()
        end
    end
end

return mainMenu
