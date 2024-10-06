local settingsMenu = {}

local button_height = 64
local font = 0
settingsMenu.buttons = {}

local racket = love.audio.newSource("game/SFX/Racket.mp3", "static")

local function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        now = false,
        last = false,
        soundPlayed = false
    }
end

function settingsMenu.load()
    font = love.graphics.newFont(32)

    table.insert(settingsMenu.buttons, newButton("Res:        640x480", function()

    end))

    table.insert(settingsMenu.buttons, newButton("Res:      1080x720", function()

    end))
    table.insert(settingsMenu.buttons, newButton("Res:    1920x1080", function()

    end))
    table.insert(settingsMenu.buttons, newButton("Res:    2560x1440", function()

    end))

    table.insert(settingsMenu.buttons, newButton("Back to Main Menu", function()
        print("Returning to Main Menu")
        mainMenu.currentMenu = "main"
    end))
end

function settingsMenu.draw()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local button_width = ww * (1 / 3)
    local buttonspace = 16
    local cursor_y = 0

    for i, button in ipairs(settingsMenu.buttons) do
        button.last = button.now

        local buttonx = (ww * 0.5) - (button_width * 0.5)
        local buttony = (wh * 0.5) - (button_height * 0.5) + cursor_y

        local color = {0, 0.6, 1}
        local mx, my = love.mouse.getPosition()
        local hover = mx > buttonx and mx < buttonx + button_width and
                my > buttony and my < buttony + button_height

        if hover then
            color = {0, 1, 0}
            if not button.soundPlayed then
                racket:play()
                button.soundPlayed = true
            end
        else
            button.soundPlayed = false
        end

        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hover then
            button.fn()
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", buttonx, buttony, button_width, button_height)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(button.text, font, (ww * 0.5) - (font:getWidth(button.text) * 0.5), buttony + (button_height / 2) - (font:getHeight(button.text) / 2))

        cursor_y = cursor_y + (button_height + buttonspace)
    end
end

return settingsMenu
