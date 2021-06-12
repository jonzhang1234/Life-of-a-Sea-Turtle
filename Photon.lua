--[[
    This is CS50 2019.
    Games Track
    Pong

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]
Photon = Class{}

function Photon:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.map = map
    self.dy = 0
    self.dx = 0
    self.coinX = {}
    self.coinY = {}
end

--[[
    Places the ball in the middle of the screen, with an initial random velocity
    on both axes.
]]
function Photon:reset()
    self.x = 115+(map.emptyX-2)*80
    self.y = 115+(map.emptyY-2)*80
    self.coinX = {}
    self.coinY = {}
end


function Photon:update(dt)
    self:checkLeftCollision()
    self:checkRightCollision()
    self:checkUpCollision()
    self:checkDownCollision()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Photon:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Photon:checkWallCollision()
    if self.x < 0 or self.x > WINDOW_WIDTH or self.y < 0 or self.y > WINDOW_HEIGHT then
        return true
    end
end

function Photon:checkCoinCollision()
    if self.dx < 0 then
        if self.map:collidesWithCoin(self.map:tileAt(self.x, self.y)) then
            table.insert(self.coinX, self.x)
            table.insert(self.coinY, self.y)
            return true
        end
    elseif self.dx > 0 then
        if self.map:collidesWithCoin(self.map:tileAt(self.x + PHOTON_SIZE, self.y)) then
            table.insert(self.coinX, self.x + PHOTON_SIZE)
            table.insert(self.coinY, self.y)
            return true
        end
    elseif self.dy < 0 then
        if self.map:collidesWithCoin(self.map:tileAt(self.x, self.y)) then
            table.insert(self.coinX, self.x)
            table.insert(self.coinY, self.y)
            return true
        end
    elseif self.dy > 0 then
        if self.map:collidesWithCoin(self.map:tileAt(self.x, self.y + PHOTON_SIZE)) then
            table.insert(self.coinX, self.x)
            table.insert(self.coinY, self.y + PHOTON_SIZE)
            return true
        end
    end
end

function Photon:checkTargetCollision()
    if self.dx < 0 then
        if self.map:collidesWithTarget(self.map:tileAt(self.x + 45, self.y)) then
            return true
        end
    elseif self.dx > 0 then
        if self.map:collidesWithTarget(self.map:tileAt(self.x - 35, self.y)) then
            return true
        end
    elseif self.dy < 0 then
        if self.map:collidesWithTarget(self.map:tileAt(self.x, self.y + 45)) then
            return true
        end
    elseif self.dy > 0 then
        if self.map:collidesWithTarget(self.map:tileAt(self.x, self.y - 35)) then
            return true
        end
    end
end

function Photon:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x , self.y)) then
            self.x = self.map:tileAt(self.x , self.y).x * self.map.tileWidth - self.map.tileWidth - PHOTON_SIZE
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x , self.y)) then
            self.x = self.map:tileAt(self.x , self.y).x * self.map.tileWidth
            self.dx = PHOTON_SPEED
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x , self.y)) then
            self.dy = -PHOTON_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x , self.y).x*self.map.tileWidth - 0.5*self.map.tileWidth - PHOTON_SIZE / 2
            self.y = self.map:tileAt(self.x , self.y).y*self.map.tileWidth - self.map.tileWidth - PHOTON_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y)) then
            self.dy = PHOTON_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth - 0.5 * self.map.tileWidth - PHOTON_SIZE / 2
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth
        end
    end
end

function Photon:checkRightCollision()
    if self.dx > 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x + PHOTON_SIZE, self.y)) then
            self.x = self.map:tileAt(self.x + PHOTON_SIZE, self.y).x * self.map.tileWidth - self.map.tileWidth
            self.dx = -PHOTON_SPEED
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x + PHOTON_SIZE, self.y)) then
            self.x = self.map:tileAt(self.x + PHOTON_SIZE, self.y).x * self.map.tileWidth
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x + PHOTON_SIZE, self.y)) then
            self.dy = -PHOTON_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x + PHOTON_SIZE, self.y).x * self.map.tileWidth - 0.5 * self.map.tileWidth - PHOTON_SIZE / 2
            self.y = (self.map:tileAt(self.x + PHOTON_SIZE, self.y).y - 1) * self.map.tileWidth - PHOTON_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x + PHOTON_SIZE, self.y)) then
            self.dy = PHOTON_SPEED
            self.dx = 0
            self.x = (self.map:tileAt(self.x + PHOTON_SIZE, self.y).x - 0.5) * self.map.tileWidth - PHOTON_SIZE / 2
            self.y = self.map:tileAt(self.x + PHOTON_SIZE, self.y).y * self.map.tileWidth
        end
    end
end

function Photon:checkUpCollision()
    if self.dy < 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x, self.y)) then
            self.dx = -PHOTON_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth - self.map.tileWidth - PHOTON_SIZE
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth - 0.5 * self.map.tileWidth - PHOTON_SIZE / 2
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x, self.y)) then
            self.dx = PHOTON_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth - 0.5*self.map.tileWidth - PHOTON_SIZE / 2
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x, self.y)) then
            self.y = (self.map:tileAt(self.x, self.y).y) * self.map.tileWidth - self.map.tileWidth - PHOTON_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y)) then
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth
            self.dy = PHOTON_SPEED
        end
    end
end

function Photon:checkDownCollision()
    if self.dy > 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x, self.y + PHOTON_SIZE)) then
            self.dx = -PHOTON_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y + PHOTON_SIZE).x * self.map.tileWidth - self.map.tileWidth - PHOTON_SIZE
            self.y = self.map:tileAt(self.x, self.y + PHOTON_SIZE).y * self.map.tileWidth - 0.5 * self.map.tileWidth - PHOTON_SIZE / 2
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x , self.y + PHOTON_SIZE)) then
            self.dx = PHOTON_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x , self.y + PHOTON_SIZE).x * self.map.tileWidth
            self.y = (self.map:tileAt(self.x , self.y + PHOTON_SIZE).y - 0.5) * self.map.tileWidth - PHOTON_SIZE / 2
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x, self.y + PHOTON_SIZE)) then
            self.y = self.map:tileAt(self.x, self.y + PHOTON_SIZE).y * self.map.tileWidth - self.map.tileWidth
            self.dy = -PHOTON_SPEED
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y + PHOTON_SIZE)) then
            self.y = (self.map:tileAt(self.x, self.y + PHOTON_SIZE).y) * self.map.tileWidth
        end
    end
end