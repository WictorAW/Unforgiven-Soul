--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'
Map = Class{}

TILE_EMPTY = -1
TILE_BROWN = 18
TILE_FGRASS = 1
TILE_DFGRASS = 9
TILE_DLGRASS = 16
TILE_LGRASS = 8


-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- constructor for our map object
function Map:init()
    --get tiles from png
    self.spritesheet = love.graphics.newImage('tiles/tilemap.png')
    --generate 16x16 quads
    self.sprites = generateQuads(self.spritesheet, 16, 16)

    --set tile width and height
    self.tileWidth = 16
    self.tileHeight = 16
    --set map width and height
    self.mapWidth = 65
    self.mapHeight = 36

    --create tiles table
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 10

    --associate player with map
    self.player = Player(self)

    --associate enemy with map
    self.enemy = Enemy(self,self.player)

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    self:fill_empty()

    -- begin generating the terrain using vertical scan lines
    self:generateTerrain()

    --MAP edge 
    self:generateEdge()

end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {9, 10, 11, 12, 13, 14, 15, 16, 29}

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

-- function to update camera offset with delta time
function Map:update(dt)

    --player and enemy update function
    self.player:update(dt)
    self.enemy:update(dt)

    --remove and update arrow and enemy hp
    self:arrowUpdate()
    
    -- keep camera's X coordinate following the player, preventing camera from
    --scrolling past 0 to the left and the map's width
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end
    --render player and enemy
    self.player:render()
    self.enemy:render()
end

function Map:arrowUpdate()
    for i, arrow in ipairs(self.player.arrows) do
        if (math.abs(arrow.x - self.enemy.x)) < 2 and self.enemy.death == false then
            table.remove(self.player.arrows,i)
            i = i - 1
            self.enemy.hp = self.enemy.hp - 10
            if self.enemy.direction == 'left' then
                self.enemy.x = self.enemy.x + 3
            else
                self.enemy.x = self.enemy.x - 3
            end
        end
    end
end
function Map:fill_empty()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end
end
function Map:generateTerrain()
    local x = 1
    local l = 1
    while x < self.mapWidth - 1 do
        -- creates column of tiles going to bottom of map
        for y = 33, self.mapHeight do
            self:setTile(x, y, TILE_BROWN)
        end   

        --generating grass
        if l ~= 9  then
            -- create grass 1 - 8
            local grass_tile = l % 10
            local grassd_tile = l % 10 + 8
            self:setTile(x, 31, grass_tile)
            self:setTile(x, 32, grassd_tile)
            l = l + 1 
            if l  >= 9 then
                l = 1
            end
        end
        -- next vertical scan line
        x = x + 1 
    end
end
function Map:generateEdge()
    self:setTile(self.mapWidth - 2, 31, 21)
    self:setTile(self.mapWidth - 2, 32, 29)
    self:setTile(self.mapWidth - 1, 32, 30)
    self:setTile(self.mapWidth - 2, 33, 35)
    self:setTile(self.mapWidth - 1, 33, 36)
    self:setTile(self.mapWidth - 2, 34, 43)
    self:setTile(self.mapWidth - 1, 34, 44)
    self:setTile(self.mapWidth - 2, 35, 51)
    self:setTile(self.mapWidth - 1, 35, 52)
    self:setTile(self.mapWidth - 2, 36, 59)
end

