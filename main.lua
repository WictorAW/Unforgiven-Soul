--[[
    Unforgiven Soul
    Author: Wictor Wilcken
    Art Credits: Tiles - https://szadiart.itch.io/pixel-dark-forest
    hero - https://oco.itch.io/medieval-fantasy-character-pack-4
    enemy -https://oco.itch.io/medieval-fantasy-character-pack-2
    code - using Lua and Love2d
    email - wictorwilcken@hotmail.com
    git - wictorAW
    ]]

Class = require 'class'
push = require 'push'

require 'Map'
require 'Player'
require 'Animation'
require 'Enemy'
require 'Arrow'

-- game width and height
VIRTUAL_WIDTH = 1024
VIRTUAL_HEIGHT = 576

-- actual window resolution
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

function love.load()
    -- sets up a different, better-looking retro font as our default
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 32)
    
    --background img
    background = love.graphics.newImage("tiles/main_background2.png")

    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --set game title
    love.window.setTitle('Unforgiven Soul')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    --call update function from Map class
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    --draw background
    local sx = love.graphics.getWidth() / background:getWidth()
    local sy = love.graphics.getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, sx, sy) -- x: 0, y: 0, rot: 0, scale x and scale y
    
    -- renders our map object onto the screen
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    
    --render map
    map:render()

    --display fps function
    displayFPS()
    
    -- end virtual resolution
    push:apply('end')
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

    
