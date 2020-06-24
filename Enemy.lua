
Enemy = Class{}

local RUN_SPEED = 100
local largeFont = love.graphics.newFont('fonts/font.ttf', 32)

function Enemy:init(map, player)

    --enemy position
    self.x = 0
    self.y = 0

    --enemy width and height
    self.width = 64
    self.height = 48

    -- offset from top left to center to support sprite flipping
    self.xOffset = 32
    self.yOffset = 24

    --instantiate map and player
    self.map = map
    self.player = player

    --get textures from png
    self.texture = love.graphics.newImage('Sprites/enemy.png')

    -- animation frames table
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    -- start looking for left
    self.scaleX = -1

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    --start position
    self.y = (map.tileHeight * 31) - self.height
    self.x = map.tileWidth * 50

    --timer to reset atack
    self.timerAtack = 1

    --timer to stop render
    self.stopRender = 5

    --hp
    self.hp = 1000

    --start alive
    self.death = false

    --enemy animations
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
                love.graphics.newQuad(512, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(576, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(640, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(704, 0, self.width, self.height, self.texture:getDimensions()),

            },
            interval = 0.08
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
            interval = 0.10
        }),
        ['atackS'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 96, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(400, 96, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(480, 96, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(560, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(624, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1920, 96, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.05
        }),
        ['atackH'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(624, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(688, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(752, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(816, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(880, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(960, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1040, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1120, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1200, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1280, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1344, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1408, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1488, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1568, 96, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1648, 96, 80, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1728, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1792, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1856, 96, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1920, 96, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.05
        }),
        ['death'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(128, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(192, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(256, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(320, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(384, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(448, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(512, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(576, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(640, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(704, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(768, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(832, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(896, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(960, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1024, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1088, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1152, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1216, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1280, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1344, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1408, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1472, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1600, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1664, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1728, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1792, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1856, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(1920, 144, self.width, 80, self.texture:getDimensions()),
                love.graphics.newQuad(2000, 144, self.width, 80, self.texture:getDimensions()),
                love.graphics.newQuad(2080, 144, self.width, 80, self.texture:getDimensions()),
                love.graphics.newQuad(2160, 144, self.width, 80, self.texture:getDimensions()),
                love.graphics.newQuad(2240, 144, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(2320, 144, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.15
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
            --enemy death
            self:checkDeath()

            --enemy mov
            if self.x > self.player.x and (math.abs(self.x - self.player.x) < 300 and math.abs(self.x - self.player.x) > 30) then
                self.direction = 'left'
                self.dx = -RUN_SPEED
                self.state = 'run'
                self.animations['run']:restart()
                self.animation = self.animations['run']
            elseif self.x < self.player.x and (math.abs(self.x - self.player.x) < 300 and math.abs(self.x - self.player.x) > 30) then
                self.direction = 'right'
                self.dx = RUN_SPEED
                self.state = 'run'
                self.animations['run']:restart()
                self.animation = self.animations['run']
            elseif math.abs(self.x - self.player.x) <= 30 and self.x > self.player.x and self.player.death == false then
                if math.random(2) == 1 then
                    self.direction = 'left'
                    self.state = 'atackH'
                    self.animation = self.animations['atackH']
                    self.animations['atackH']:restart()
                    self.dx = 0
                elseif math.random(2) == 2 then
                    self.direction = 'left'
                    self.state = 'atackS'
                    self.animation = self.animations['atackS']
                    self.animations['atackS']:restart()
                    self.dx = 0
                end
            elseif math.abs(self.x - self.player.x) <= 30 and self.x < self.player.x and self.player.death == false then
                if math.random(2) == 1 then
                    self.direction = 'right'
                    self.state = 'atackH'
                    self.animation = self.animations['atackH']
                    self.animations['atackH']:restart()
                    self.dx = 0
                elseif math.random(2) == 2 then
                    self.direction = 'right'
                    self.state = 'atackS'
                    self.animation = self.animations['atackS']
                    self.animations['atackS']:restart()
                    self.dx = 0
                end
            end
        end,
        ['run'] = function(dt)
            --enemy death
            self:checkDeath()

            --enemy moviment
            if self.x > self.player.x  and (math.abs(self.x - self.player.x) < 300 and math.abs(self.x - self.player.x) > 30) then
                self.direction = 'left'
                self.dx = -RUN_SPEED
            elseif self.x < self.player.x and (math.abs(self.x - self.player.x) < 300 and math.abs(self.x - self.player.x) > 30) then
                self.direction = 'right'
                self.dx = RUN_SPEED
            elseif math.abs(self.x - self.player.x) <= 30 and self.x > self.player.x and self.player.death == false then
                if math.random(2) == 1 then
                    self.direction = 'left'
                    self.state = 'atackH'
                    self.animation = self.animations['atackH']
                    self.animations['atackH']:restart()
                    self.dx = 0
                elseif math.random(2) == 2 then
                    self.direction = 'left'
                    self.state = 'atackS'
                    self.animation = self.animations['atackS']
                    self.animations['atackS']:restart()
                    self.dx = 0
                end
            elseif math.abs(self.x - self.player.x) <= 30 and self.x < self.player.x and self.player.death == false then
                if math.random(2) == 1 then
                    self.direction = 'right'
                    self.state = 'atackH'
                    self.animation = self.animations['atackH']
                    self.animations['atackH']:restart()
                    self.dx = 0
                elseif math.random(2) == 2 then
                    self.direction = 'right'
                    self.state = 'atackS'
                    self.animation = self.animations['atackS']
                    self.animations['atackS']:restart()
                    self.dx = 0
                end
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
    
        -- check for collisions moving left and right
        self:checkRightCollision()
        self:checkLeftCollision()
        end,
        ['atackH'] = function(dt)
            --enemy death
            self:checkDeath()
        
            if self.timerAtack <= 0 and self.x < self.player.x then
                self.dx = 0
                self.direction = 'right'
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.timerAtack = 1
            elseif self.timerAtack <= 0 and self.x > self.player.x then
                self.dx = 0
                self.direction = 'left'
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.timerAtack = 1
            end
            
            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end,
        ['atackS'] = function(dt)
            --enemy death
            self:checkDeath()

            if self.timerAtack <= 0 and self.x < self.player.x then
                self.dx = 0
                self.direction = 'right'
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.timerAtack = 1
            elseif self.timerAtack <= 0 and self.x > self.player.x then
                self.dx = 0
                self.direction = 'left'
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.timerAtack = 1
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end,
        ['death'] = function(dt)
            self.dx = 0
        end
    }
end
-- checks two tiles to our left to see if a collision occurred
function Enemy:checkLeftCollision()
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
function Enemy:checkRightCollision()
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

function Enemy:update(dt)

    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt

    --atack timer
    self.timerAtack = self.timerAtack - dt

    -- apply velocity
    self.y = self.y + self.dy * dt
    
    --player damage update
    if self.state == 'atackH' and self.animations['atackH'].currentFrame == 19 then
        if self.y == self.player.y and math.abs(self.x - self.player.x) <= 30 then
            self.player.hp = self.player.hp - 100
        end
    elseif self.state == 'atackS' and self.animations['atackS'].currentFrame == 10 then
        if self.y == self.player.y and math.abs(self.x - self.player.x) <= 30 then
            self.player.hp = self.player.hp - 30
        end
    end
    if self.hp <= 0 then
        self.death = true
        self.stopRender = self.stopRender - dt
    end
    if love.keyboard.wasPressed('l') then
        love.event.quit( 'restart' )
    end
    
end

function Enemy:render()
    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        self.scaleX = 1
    else
        self.scaleX = -1
    end
    -- draw sprite with scale factor and offsets
    if self.stopRender > 0 then
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
            math.floor(self.y + self.yOffset), 0, self.scaleX, 1, self.xOffset, self.yOffset)
    end
    if self.hp <= 0 then
        self:displayWin()
    end
end
function Enemy:displayWin()
    -- simple FPS display across all states
    love.graphics.setFont(largeFont)
    love.graphics.print('You Win', 1024/2 - 50, 30)
    love.graphics.print('Press L to reset', 1024/2 - 130, 100)
end

function Enemy:checkDeath()
    if self.death then
        self.state = 'death'
        self.animation = self.animations['death']
        self.dx = 0
    end
end
