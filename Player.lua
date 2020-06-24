--[[
    Represents our player in the game, with its own sprite.
]]
Player = Class{}

local RUN_SPEED = 110
local JUMP_VELOCITY = 400
local ARROW_SPEED = 300

local largeFont = love.graphics.newFont('fonts/font.ttf', 32)

function Player:init(map)

    --player position
    self.x = 0
    self.y = 0

    --player width and height
    self.width = 64
    self.height = 48

    -- offset from top left to center to support sprite flipping
    self.xOffset = 32
    self.yOffset = 24

    self.arrows = {}
    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('Sprites/run_idle3.png')

    -- animation frames
    self.frames = {}
    
    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'right'

    --turn right or left
    self.scaleX = 1

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = (map.tileHeight * 31) - self.height
    self.x = map.tileWidth * 5

    --hp and death state
    self.hp = 100
    self.death = false;
    self.stopRender = 4

    --player animation logic
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(448, 0, self.width, self.height, self.texture:getDimensions()),

            },
            interval = 0.15
        }),
        ['run'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(448, 48, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 96, self.height, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(448, 96, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.08
        }),
        ['shooting'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 208, self.height, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 208, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(448, 208, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.05
        }),
        ['death'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 256, self.height, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 256, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 144, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(400, 144, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(432, 256, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(432, 304, 80, 32, self.texture:getDimensions()),
            },
            interval = 0.4
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
    self.lastFrame = self.animation:getLastFrame();


    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)

            --check death
            self:checkDeath()

            -- add spacebar functionality to trigger jump state
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -RUN_SPEED
                self.state = 'run'
                self.animations['run']:restart()
                self.animation = self.animations['run']
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = RUN_SPEED
                self.state = 'run'
                self.animations['run']:restart()
                self.animation = self.animations['run']
            elseif love.keyboard.wasPressed('e')then
                self.state = 'shooting'
                self.animation = self.animations['shooting']
            else
                self.dx = 0
            end
        end,
        ['run'] = function(dt)

            --check death
            self:checkDeath()

            -- keep track of input to switch movement while run, or reset
            -- to idle if we're not moving
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -RUN_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = RUN_SPEED
            elseif love.keyboard.wasPressed('e') then
                self.state = 'shooting'
                self.animation = self.animations['shooting']
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()

            -- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
            
                -- if so, reset velocity and position and change state
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)

            --check death
            self:checkDeath()

            -- break if we go below the surface
            if self.y > 600 then
                self.death = true
                return
            end

            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -RUN_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = RUN_SPEED
            end

            -- apply map's gravity before y velocity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end,
        ['shooting'] = function(dt)
            --check death
            self:checkDeath()

            -- shot a arrow when e is released
            if love.keyboard.keysReleased['e'] then
                --insert arrow
                if self.direction == 'right' and self.state == 'shooting' then
                    table.insert(self.arrows, Arrow(self.x, self.y + 14, ARROW_SPEED, self.map.gravity))
                elseif self.direction == 'left' and self.state == 'shooting' then
                    table.insert(self.arrows, Arrow(self.x, self.y + 14, -ARROW_SPEED, self.map.gravity))
                end
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end,
        ['death'] = function(dt)
            self.dx = 0
        end
    }
end

function Player:update(dt)

    --remove and update arrow
    self:removeArrow(dt)

    --update animation and behavior
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()

    --update player position with run velocity
    self.x = self.x + self.dx * dt
     
    self:calculateJumps()
    
    -- apply velocity
    self.y = self.y + self.dy * dt

    -- stop render if dead
    if self.hp <= 0 then
        self.death = true
        self.stopRender = self.stopRender - dt 
    end
end

function Player:render()
    
    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    self:changeDirection()
    
    --draw arrow in arrows
    self:drawArrow()

    -- draw sprite with scale factor and offsets
    if self.stopRender > 0 then
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, self.scaleX, 1, self.xOffset, self.yOffset)
    end

    --check lose
    if self.hp <= 0 then
        self:displayLose()
    end
end

-- jumping logic
function Player:calculateJumps()
    
    -- if we have negative y velocity (jumping), check if we collide
    -- with any blocks above us
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
            -- reset y velocity
            self.dy = 0
        end
    end
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width / 2, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width / 2, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:displayLose()
    -- simple FPS display across all states
    love.graphics.setFont(largeFont)
    love.graphics.print('You Lose', 1024/2 - 50, 30)
    love.graphics.print('Press L to reset', 1024/2 - 130, 100)
end

function Player:drawArrow()
    for i, arrow in ipairs(self.arrows) do
        arrow:render()
    end
end

function Player:changeDirection()
    if self.direction == 'right' then
        self.scaleX = 1
    else
        self.scaleX = -1
    end
end

--remove and update arrow
function Player:removeArrow(dt)
    for i, arrow in ipairs(self.arrows) do
        if arrow.remove then
            table.remove(self.arrows,i)
            i = i - 1
        else
            arrow:update(dt)
        end
    end
end

function Player:checkDeath()
    if self.death then
        self.state = 'death'
        self.animation = self.animations['death']
        self.dx = 0
    end
end
