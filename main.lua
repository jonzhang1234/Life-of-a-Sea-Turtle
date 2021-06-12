
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering thems

-- our photon class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Photon'
require 'Map'


math.randomseed(os.time())
map = Map()

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


PHOTON_SPEED = 200
PHOTON_SIZE = 10

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Photon')


    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('Quantum.otf', 28)
    largeFont = love.graphics.newFont('Quantum.otf', 32)
    scoreFont = love.graphics.newFont('Quantum.otf', 64)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- initialize window with virtual resolution
    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    score = 0
    level = 1

    photon = Photon(115+(map.emptyX-2)*80, 115+(map.emptyY-2)*80, 10, 10)

    gameState = 'start'
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
        photon.dx = PHOTON_SPEED
        photon.dy = 0
    elseif gameState == 'play' then
        photon:update(dt)
        if photon:checkWallCollision() == true then
            gameState = 'defeat'
        end
        if photon:checkCoinCollision() == true then
            if photon.dx < 0 then
                map:setTile(math.floor(photon.x/80)+1, math.floor(photon.y/80)+1, TILE_EMPTY)
                score = score + 1
            elseif photon.dx > 0 then
                map:setTile(math.floor((photon.x+10)/80)+1, math.floor(photon.y/80)+1, TILE_EMPTY)
                score = score + 1
            elseif photon.dy < 0 then
                map:setTile(math.floor(photon.x/80)+1, math.floor(photon.y/80)+1, TILE_EMPTY)
                score = score + 1
            elseif photon.dy > 0 then
                map:setTile(math.floor(photon.x/80)+1, math.floor((photon.y+10)/80)+1, TILE_EMPTY)
                score = score + 1
            end
        end
        if photon:checkTargetCollision() == true then
            gameState = 'victory'
        end
    end
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'shoot'
        elseif gameState == 'defeat' then
            gameState = 'shoot'
            score = score - getTableSize(photon.coinX)
            for x = 1, getTableSize(photon.coinX) do
                map:setTile(math.floor(photon.coinX[x]/80) + 1, math.floor(photon.coinY[x]/80) + 1, 6)
            end
            for x = 1, getTableSize(photon.coinX) do
                table.remove(photon.coinX, photon.coinX[x])
            end
            for y = 1, getTableSize(photon.coinY) do
                table.remove(photon.coinY, photon.coinY[y])
            end
            photon:reset()
        elseif gameState == 'victory' then
            level = level + 1
            gameState = 'shoot'
            map:init()
            photon:reset()
        end
    elseif key == 'left'then
        if gameState == 'shoot' then
            gameState = 'play'
            photon.dx = -PHOTON_SPEED
            photon.dy = 0
        end
    elseif key == 'right' then
        if gameState == 'shoot' then
            gameState = 'play'
            photon.dx = PHOTON_SPEED
            photon.dy = 0
        end
    elseif key == 'up' then
        if gameState == 'shoot' then
            gameState = 'play'
            photon.dx = 0
            photon.dy = -PHOTON_SPEED
        end
    elseif key == 'down' then
        if gameState == 'shoot' then
            gameState = 'play'
            photon.dx = 0
            photon.dy = PHOTON_SPEED
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(0/255, 0/255, 0/255, 0/255)
    displayScore()
    displayLevel()

    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Welcome to Photon!', 0, 15, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to begin!', 0, 40, WINDOW_WIDTH, 'center')
    elseif gameState == 'shoot' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('use the arrow keys to shoot', 0, 5, WINDOW_WIDTH, 'center')
        love.graphics.printf('click on an arrow to change its direction', 0, 25, WINDOW_WIDTH, 'center')
        love.graphics.printf('collect coins and make it to the target!', 0, 45, WINDOW_WIDTH, 'center')
    elseif gameState == 'defeat' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('you lost', 0, 10, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to try again!', 0, 30, WINDOW_WIDTH, 'center')
    elseif gameState == 'victory' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('you won!', 0, 10, WINDOW_WIDTH, 'center')
        love.graphics.printf('press enter to play again!', 0, 30, WINDOW_WIDTH, 'center')
    end

    map:render()
    photon:render()

    displayFPS()

    push:apply('end')
end

--[[
    Renders the current FPS.
]]
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
