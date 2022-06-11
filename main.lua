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
player_SIZE = 75


function love.load()

    image = love.graphics.newImage("kelp.png")
    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('player')


    smallFont = love.graphics.newFont('San.ttf', 24)
    largeFont = love.graphics.newFont('San.ttf', 30)
    scoreFont = love.graphics.newFont('San.ttf', 64)
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


    Player = Player(120-0.5*player_SIZE+(map.emptyX-2)*80, 120-0.5*player_SIZE+(map.emptyY-2)*80, player_SIZE, player_SIZE)

    gameState = 'start'
	playerState = 'unmasked'
    orientation = 'up'
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
        if Player.dy == 0 and Player.dx < 0 then
            orientation = 'left'
        elseif Player.dy == 0 and Player.dx >= 0  then    
            orientation = 'right'
        elseif Player.dx ==0 and Player.dy < 0 then
            orientation = 'up'
        elseif Player.dx == 0 and Player.dy >= 0  then
            orientation = 'down'
        end
        if Player:checkWallCollision() == true then
            gameState = 'fell'
            playerState = 'unmasked'
        end
        if Player:checkVirusCollision() == true then
			if playerState == 'unmasked' then
				gameState = 'defeat'
			elseif playerState == 'masked' then
				if Player.dx < 0 then
				    map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
				elseif Player.dx > 0 then
					map:setTile(math.floor((Player.x+player_SIZE)/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
	            elseif Player.dy < 0 then
		            map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
			    elseif Player.dy > 0 then
			        map:setTile(math.floor(Player.x/80)+1, math.floor((Player.y+player_SIZE)/80)+1, TILE_EMPTY)
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
                map:setTile(math.floor((Player.x+player_SIZE)/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy < 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy > 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor((Player.y+player_SIZE)/80)+1, TILE_EMPTY)
            end
        end
        if Player:checkTpaperCollision() == true then
            if Player.dx < 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dx > 0 then
                map:setTile(math.floor((Player.x+player_SIZE)/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy < 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor(Player.y/80)+1, TILE_EMPTY)
            elseif Player.dy > 0 then
                map:setTile(math.floor(Player.x/80)+1, math.floor((Player.y+player_SIZE)/80)+1, TILE_EMPTY)
            end
            gameState = 'victory'
            playerState = 'unmasked'
            score = score + 1
        end
        if Player:checkVaccineCollision() == true then
            gameState = 'finished'
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

local COLOR_MUL = love._version >= "11.0" and 1 or 255

function gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

mesh = gradientMesh('vertical', {0, 169, 204}, {0, 0, 255})

function love.draw()
    push:apply('start')

    love.graphics.clear(0, 0, 0, 0)
    love.graphics.draw(mesh, 0, 0, 0, love.graphics.getDimensions())
    love.graphics.draw(image, -100, 230)
    love.graphics.draw(image, 125, 220)
    love.graphics.draw(image, 350, 230)
    love.graphics.draw(image, 575, 220)
    love.graphics.draw(image, 800, 230)
    love.graphics.draw(image, 1025, 220)
    
    displayScore()
    displayLevel()

    if level ~=6 then
        if gameState == 'start' then
            love.graphics.printf('WELCOME TO LIFE OF A SEA TURTLE!', 0, 15, WINDOW_WIDTH, 'center')
            love.graphics.printf('PRESS ENTER TO BEGIN!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'shoot' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('USE THE ARROW KEYS TO START SWIMMING', 0, 5, WINDOW_WIDTH, 'center')
            love.graphics.printf('CLICK ON AN ARROW TO CHANGE THE DIRECTION OF THE CURRENT', 0, 25, WINDOW_WIDTH, 'center')
            love.graphics.printf('AVOID PLASTIC BAGS AND MAKE IT TO THE JELLYFISH', 0, 45, WINDOW_WIDTH, 'center')
        elseif gameState == 'defeat' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you choked on a plastic bag', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('press enter to try again!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'fell' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you went too far', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('press enter to try again!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'victory' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you got the jellyfish!', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('press enter to get to the next one!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'finished' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you got to the beach!', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('you can now lay eggs without fear!', 0, 40, WINDOW_WIDTH, 'center')
            turtle = love.graphics.newImage("turtle_up.png")
            for i in range(100) do
                love.graphics.draw(turtle, math.random(2, self.mapWidth - 1), math.random(2, self.mapHeight - 1), math.random(0, 6.28), self.width/497/2, self.height/497/2)
            end
        end
    end

    if level == 6 or level == 7 then
        if gameState == 'shoot' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('use the arrow keys to start swimming', 0, 5, WINDOW_WIDTH, 'center')
            love.graphics.printf('click on an arrow to change its direction', 0, 25, WINDOW_WIDTH, 'center')
            love.graphics.printf('avoid the bags and make it to the beach!', 0, 45, WINDOW_WIDTH, 'center')
        elseif gameState == 'defeat' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you choked on a plastic bag', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('press enter to try again!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'fell' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you went too far', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('press enter to try again!', 0, 40, WINDOW_WIDTH, 'center')
        elseif gameState == 'finished' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('you got to the beach!', 0, 10, WINDOW_WIDTH, 'center')
            love.graphics.printf('you can now lay eggs without fear!', 0, 40, WINDOW_WIDTH, 'center')
            turtle = love.graphics.newImage("turtle_up.png")
            for i=1, 100, 1 do
                love.graphics.draw(turtle, math.random(2, 16*80- 1), math.random(2, 9*80 - 1), math.random(0, 6.28), player_SIZE/497/2, player_SIZE/497/2)
            end
        end
    end

    map:render()

    if orientation == 'up' then
        Player:renderUp()
    elseif orientation == 'right' then
        Player:renderRight()
    elseif orientation == 'down' then
        Player:renderDown()
    elseif orientation == 'left' then
        Player:renderLeft()
    end

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
