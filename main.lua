push = require 'push'

Class = require 'class'

require 'Player'
require 'Map'

level = 1
score = 0

math.randomseed(os.time())
map = Map()

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


player_SPEED = 200
player_SIZE = 10


function love.load()
    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('player')


    smallFont = love.graphics.newFont('Quantum.otf', 28)
    largeFont = love.graphics.newFont('Quantum.otf', 32)
    scoreFont = love.graphics.newFont('Quantum.otf', 64)
    love.graphics.setFont(smallFont)

--[[    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
]]
    -- initialize window with virtual resolution
    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner


    Player = Player(115+(map.emptyX-2)*80, 115+(map.emptyY-2)*80, 10, 10)

    gameState = 'start'
	playerState = 'unmasked'
end

--[[
    Called by LÖVE whenever we resize the screen; here, we just want to pass in the
    width and height to push so our virtual resolution can be resized as needed.
]]
function love.resize(w, h)
    push:resize(w, h)
end


function love.mousepressed(x, y, button)
    if button == 1 then
        tileX = x
        tileY = y 
        if map:getTile(math.floor(tileX/80)+1, math.floor(tileY/80)+1) > 0 
        and map:getTile(math.floor(tileX/80)+1, math.floor(tileY/80)+1) < 5 then
            map:setTile(math.floor(tileX/80)+1, math.floor(tileY/80)+1, 
            (map:getTile(math.floor(tileX/80)+1, math.floor(tileY/80)+1))%4+1)
        end
    end
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    if gameState == 'shoot' then
        Player.dx = player_SPEED
        Player.dy = 0
    elseif gameState == 'play' then
        Player:update(dt)
        if Player:checkWallCollision() == true then
            gameState = 'fell'
        end
        if Player:checkVirusCollision() == true then
			if playerState == 'unmasked' then
				gameState = 'defeat'
			elseif playerState == 'masked' then
				if Player.dx < 0 then
				    map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
				elseif Player.dx > 0 then
					map:setTile(math.floor((Player.x+10)/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
	            elseif Player.dy < 0 then
		            map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
			    elseif Player.dy > 0 then
			        map:setTile(math.floor(Player.x/80)+1, math.floor((Player.y+10)/80)+1, TILE_EMPTY)
			    end
				playerState = 'unmasked'
			end
        end
        if Player:checkMaskCollision() == true then
			if playerState == 'unmasked' then
				playerState = 'masked'
			end
            if Player.dx < 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dx > 0 then
                map:setTile(math.floor((Player.x+10)/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy < 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy > 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor((Player.y+10)/80)+1, TILE_EMPTY)
            end
        end
        if Player:checkVaccineCollision() == true then
            gameState = 'victory'
            score = score + 1
        end
    end
end

function love.keypressed(key)

    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'shoot'
        elseif gameState == 'defeat' or gameState == 'fell' then
            gameState = 'shoot'
            score = score - getTableSize(Player.maskX)
            for x = 1, getTableSize(Player.maskX) do
                map:setTile(math.floor(Player.maskX[x]/80) + 1, math.floor(Player.maskY[x]/80) + 1, 6)
            end
            for x = 1, getTableSize(Player.maskX) do
                table.remove(Player.maskX, Player.maskX[x])
            end
            for y = 1, getTableSize(Player.maskY) do
                table.remove(Player.maskY, Player.maskY[y])
            end
            Player:reset()
        elseif gameState == 'victory' then
            level = level + 1
            gameState = 'shoot'
            map:init()
            Player:reset()
        end
    elseif key == 'left'then
        if gameState == 'shoot' then
            gameState = 'play'
            Player.dx = -player_SPEED
            Player.dy = 0
        end
    elseif key == 'right' then
        if gameState == 'shoot' then
            gameState = 'play'
            Player.dx = player_SPEED
            Player.dy = 0
        end
    elseif key == 'up' then
        if gameState == 'shoot' then
            gameState = 'play'
            Player.dx = 0
            Player.dy = -player_SPEED
        end
    elseif key == 'down' then
        if gameState == 'shoot' then
            gameState = 'play'
            Player.dx = 0
            Player.dy = player_SPEED
        end

    elseif key == 'escape' then
        map:init()
        Player:reset()
	end
end


function love.draw()
    push:apply('start')

    love.graphics.clear(0/255, 0/255, 0/255, 0/255)
    displayScore()
    displayLevel()

    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Welcome to player!', 0, 15, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to begin!', 0, 40, WINDOW_WIDTH, 'center')
    elseif gameState == 'shoot' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('use the arrow keys to shoot', 0, 5, WINDOW_WIDTH, 'center')
        love.graphics.printf('click on an arrow to change its direction', 0, 25, WINDOW_WIDTH, 'center')
        love.graphics.printf('collect masks and make it to the target!', 0, 45, WINDOW_WIDTH, 'center')
    elseif gameState == 'defeat' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('you contracted COVID-19', 0, 10, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to try again!', 0, 30, WINDOW_WIDTH, 'center')
	elseif gameState == 'fell' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('you fell out of the hospital', 0, 10, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to try again!', 0, 30, WINDOW_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('you won!', 0, 10, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to play again!', 0, 30, WINDOW_WIDTH, 'center')
    end

    map:render()
    Player:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(largeFont)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(largeFont)
    love.graphics.printf('SCORE:' .. tostring(score), 0, 10, WINDOW_WIDTH-10, 'right')
end

function displayLevel()
    love.graphics.setFont(largeFont)
    love.graphics.printf('LEVEL:' .. tostring(level), 0, 35, WINDOW_WIDTH-10, 'right')
end

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end
