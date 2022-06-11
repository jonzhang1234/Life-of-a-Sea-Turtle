--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}


TILE_EMPTY = -1
DOWN_ARROW = 1
LEFT_ARROW = 2
UP_ARROW = 3
RIGHT_ARROW = 4
TPAPER = 5
MASK = 6
VIRUS = 7
VACCINE = 8

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/Turtlespritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 80, 80)

    self.tileWidth = 80
    self.tileHeight = 80
    self.mapWidth = 16
    self.mapHeight = 9
    self.tiles = {}
    self.emptyX = math.random(2, self.mapWidth - 1)
    self.emptyY = math.random(2, self.mapHeight - 1)





    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight  do
        for x = 1, self.mapWidth  do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end


    for x = 1, math.random(23-level, 26-level) do
        self:setTile(math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), math.random(4))
        x = x + 1
    end

    for x = 1, math.random(4, 8) do
        self:setTile(math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), VIRUS)
        x = x + 1
    end
    
    for x = 1, math.random(8, 10) do
        self:setTile(math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), MASK)
        x = x + 1
    end

    if level~=6 then
        self:setTile(math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), TPAPER)
    end
    
    if level==6 then
        self:setTile(math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), VACCINE)
    end

    while self.emptyX == math.random(2, self.mapWidth - 1) and self.emptyY == math.random(2, self.mapHeight - 1) do
        self.emptyX = math.random(2, self.mapWidth - 1)
        self.emptyY = math.random(2, self.mapHeight - 1)
    end

    self:setTile(self.emptyX, self.emptyY, TILE_EMPTY)

end

function Map:reset()
    Map:init()
end

-- return whether a given tile is collidable
function Map:collidesWithLeftArrow(tile)
    if tile.id == LEFT_ARROW then
        return true
    end
    return false
end

function Map:collidesWithRightArrow(tile)
    if tile.id == RIGHT_ARROW then
        return true
    end
    return false
end

function Map:collidesWithUpArrow(tile)
    if tile.id == UP_ARROW then
        return true
    end
    return false
end

function Map:collidesWithDownArrow(tile)
    if tile.id == DOWN_ARROW then
        return true
    end
    return false
end

function Map:collidesWithTpaper(tile)
    if tile.id == TPAPER then
        return true
    end
    return false
end

function Map:collidesWithVaccine(tile)
    if tile.id == VACCINE then
        return true
    end
    return false
end

function Map:collidesWithMask(tile)
    if tile.id == MASK then
        return true
    end
    return false
end

function Map:collidesWithVirus(tile)
    if tile.id == VIRUS then
        return true
    end
    return false
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
end
