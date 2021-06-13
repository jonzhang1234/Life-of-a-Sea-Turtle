Player = Class{}

function Player:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.map = map
    self.dy = 0
    self.dx = 0
    self.maskX = {}
    self.maskY = {}
end


function Player:reset()
    self.x = 115+(map.emptyX-2)*80
    self.y = 115+(map.emptyY-2)*80
    self.maskX = {}
    self.maskY = {}
end


function Player:update(dt)
    self:checkLeftCollision()
    self:checkRightCollision()
    self:checkUpCollision()
    self:checkDownCollision()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Player:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Player:checkWallCollision()
    if self.x < 0 or self.x > WINDOW_WIDTH or self.y < 0 or self.y > WINDOW_HEIGHT then
        return true
    end
end

function Player:checkMaskCollision()
    if self.dx < 0 then
        if self.map:collidesWithMask(self.map:tileAt(self.x, self.y)) then
            table.insert(self.maskX, self.x)
            table.insert(self.maskY, self.y)
            return true
        end
    elseif self.dx > 0 then
        if self.map:collidesWithMask(self.map:tileAt(self.x + player_SIZE, self.y)) then
            table.insert(self.maskX, self.x + player_SIZE)
            table.insert(self.maskY, self.y)
            return true
        end
    elseif self.dy < 0 then
        if self.map:collidesWithMask(self.map:tileAt(self.x, self.y)) then
            table.insert(self.maskX, self.x)
            table.insert(self.maskY, self.y)
            return true
        end
    elseif self.dy > 0 then
        if self.map:collidesWithMask(self.map:tileAt(self.x, self.y + player_SIZE)) then
            table.insert(self.maskX, self.x)
            table.insert(self.maskY, self.y + player_SIZE)
            return true
        end
    end
end

function Player:checkVirusCollision()
    if self.dx < 0 then
        if self.map:collidesWithVirus(self.map:tileAt(self.x, self.y)) then
            return true
        end
    elseif self.dx > 0 then
        if self.map:collidesWithVirus(self.map:tileAt(self.x + player_SIZE, self.y)) then
            return true
        end
    elseif self.dy < 0 then
        if self.map:collidesWithVirus(self.map:tileAt(self.x, self.y)) then
            return true
        end
    elseif self.dy > 0 then
        if self.map:collidesWithVirus(self.map:tileAt(self.x, self.y + player_SIZE)) then
            return true
        end
    end
end

function Player:checkVaccineCollision()
    if self.dx < 0 then
        if self.map:collidesWithVaccine(self.map:tileAt(self.x + 45, self.y)) then
            return true
        end
    elseif self.dx > 0 then
        if self.map:collidesWithVaccine(self.map:tileAt(self.x - 35, self.y)) then
            return true
        end
    elseif self.dy < 0 then
        if self.map:collidesWithVaccine(self.map:tileAt(self.x, self.y + 45)) then
            return true
        end
    elseif self.dy > 0 then
        if self.map:collidesWithVaccine(self.map:tileAt(self.x, self.y - 35)) then
            return true
        end
    end
end

function Player:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x , self.y)) then
            self.x = self.map:tileAt(self.x , self.y).x * self.map.tileWidth - self.map.tileWidth - player_SIZE
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x , self.y)) then
            self.x = self.map:tileAt(self.x , self.y).x * self.map.tileWidth
            self.dx = player_SPEED
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x , self.y)) then
            self.dy = -player_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x , self.y).x*self.map.tileWidth - 0.5*self.map.tileWidth - player_SIZE / 2
            self.y = self.map:tileAt(self.x , self.y).y*self.map.tileWidth - self.map.tileWidth - player_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y)) then
            self.dy = player_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth - 0.5 * self.map.tileWidth - player_SIZE / 2
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth
        end
    end
end

function Player:checkRightCollision()
    if self.dx > 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x + player_SIZE, self.y)) then
            self.x = self.map:tileAt(self.x + player_SIZE, self.y).x * self.map.tileWidth - self.map.tileWidth
            self.dx = -player_SPEED
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x + player_SIZE, self.y)) then
            self.x = self.map:tileAt(self.x + player_SIZE, self.y).x * self.map.tileWidth
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x + player_SIZE, self.y)) then
            self.dy = -player_SPEED
            self.dx = 0
            self.x = self.map:tileAt(self.x + player_SIZE, self.y).x * self.map.tileWidth - 0.5 * self.map.tileWidth - player_SIZE / 2
            self.y = (self.map:tileAt(self.x + player_SIZE, self.y).y - 1) * self.map.tileWidth - player_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x + player_SIZE, self.y)) then
            self.dy = player_SPEED
            self.dx = 0
            self.x = (self.map:tileAt(self.x + player_SIZE, self.y).x - 0.5) * self.map.tileWidth - player_SIZE / 2
            self.y = self.map:tileAt(self.x + player_SIZE, self.y).y * self.map.tileWidth
        end
    end
end

function Player:checkUpCollision()
    if self.dy < 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x, self.y)) then
            self.dx = -player_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth - self.map.tileWidth - player_SIZE
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth - 0.5 * self.map.tileWidth - player_SIZE / 2
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x, self.y)) then
            self.dx = player_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y).x * self.map.tileWidth
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth - 0.5*self.map.tileWidth - player_SIZE / 2
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x, self.y)) then
            self.y = (self.map:tileAt(self.x, self.y).y) * self.map.tileWidth - self.map.tileWidth - player_SIZE
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y)) then
            self.y = self.map:tileAt(self.x, self.y).y * self.map.tileWidth
            self.dy = player_SPEED
        end
    end
end

function Player:checkDownCollision()
    if self.dy > 0 then
        if self.map:collidesWithLeftArrow(self.map:tileAt(self.x, self.y + player_SIZE)) then
            self.dx = -player_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x, self.y + player_SIZE).x * self.map.tileWidth - self.map.tileWidth - player_SIZE
            self.y = self.map:tileAt(self.x, self.y + player_SIZE).y * self.map.tileWidth - 0.5 * self.map.tileWidth - player_SIZE / 2
        elseif self.map:collidesWithRightArrow(self.map:tileAt(self.x , self.y + player_SIZE)) then
            self.dx = player_SPEED
            self.dy = 0
            self.x = self.map:tileAt(self.x , self.y + player_SIZE).x * self.map.tileWidth
            self.y = (self.map:tileAt(self.x , self.y + player_SIZE).y - 0.5) * self.map.tileWidth - player_SIZE / 2
        elseif self.map:collidesWithUpArrow(self.map:tileAt(self.x, self.y + player_SIZE)) then
            self.y = self.map:tileAt(self.x, self.y + player_SIZE).y * self.map.tileWidth - self.map.tileWidth
            self.dy = -player_SPEED
        elseif self.map:collidesWithDownArrow(self.map:tileAt(self.x, self.y + player_SIZE)) then
            self.y = (self.map:tileAt(self.x, self.y + player_SIZE).y) * self.map.tileWidth
        end
    end
end