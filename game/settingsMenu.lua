local settingsMenu = {}

local button_height = 64
local font = 0
settingsMenu.buttons = {}

local racket = love.audio.newSource("game/SFX/Racket.mp3", "static")
local volume = 0.5

mapsize = 1

local function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        soundPlayed = false
    }
end

local resolutionToSize = {
    ["1080x720"] = 1,
    ["1920x1080"] = 2,
    ["2560x1440"] = 3
}

function settingsMenu.load()
    font = love.graphics.newFont(32)

    table.insert(settingsMenu.buttons, newButton("Res:      1080x720", function()
        setResolution("1080x720")
        mapsize = 1
    end))

    table.insert(settingsMenu.buttons, newButton("Res:    1920x1080", function()
        setResolution("1920x1080")
        mapsize = 2
    end))

    table.insert(settingsMenu.buttons, newButton("Res:    2560x1440", function()
        setResolution("2560x1440")
        mapsize = 3
    end))

    table.insert(settingsMenu.buttons, newButton("Volume Up", function()
        volume = math.min(volume + 0.1, 1)
        love.audio.setVolume(volume)
        print("Volume increased to: " .. volume)
    end))

    table.insert(settingsMenu.buttons, newButton("Volume Down", function()
        volume = math.max(volume - 0.1, 0)
        love.audio.setVolume(volume)
        print("Volume decreased to: " .. volume)
    end))

    table.insert(settingsMenu.buttons, newButton("Back to Main Menu", function()
        print("Returning to Main Menu")
        switchToMainMenu()
    end))
end

function settingsMenu.draw()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print("Current Resolution: " .. ww .. "x" .. wh, 10, 10)
    love.graphics.print("Current Volume: " .. math.floor(volume * 100) .. "%", 10, 50)

    local button_width = ww * (1 / 3)
    local buttonspace = 16
    local cursor_y = -200

    for i, button in ipairs(settingsMenu.buttons) do
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

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", buttonx, buttony, button_width, button_height)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(button.text, font, (ww * 0.5) - (font:getWidth(button.text) * 0.5), buttony + (button_height / 2) - (font:getHeight(button.text) / 2))

        cursor_y = cursor_y + (button_height + buttonspace)
    end
end

function setResolution(res)
    local width, height

    if res == "1080x720" then
        width, height = 1080, 720
        screenHeight = 720
        screenWidth = 1080
    elseif res == "1920x1080" then
        width, height = 1920, 1080
        screenHeight = 1080
        screenWidth = 1920
    elseif res == "2560x1440" then
        width, height = 2560, 1440
        screenHeight = 1440
        screenWidth = 2560
    end

    love.window.setMode(width, height)
    print("Changed Resolution to: " .. width .. "x" .. height)

    resetGame()
end

return settingsMenu
