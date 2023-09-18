-- Constants
local BACKGROUND_SPEED = 3
local TILE_SIZE = 16
local VIRTUAL_WIDTH = 432

-- Helper function to draw background
local function drawBackground(background, backgroundX)
    for offset = 0, 256, 256 do
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][background],
            math.floor(-backgroundX + offset), 0)
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][background],
            math.floor(-backgroundX + offset), gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    end
end

-- Initialize player state machine
local function initPlayerStateMachine(player, gravityAmount)
    return StateMachine {
        ['idle'] = function()
            return PlayerIdleState(player)
        end,
        ['walking'] = function()
            return PlayerWalkingState(player)
        end,
        ['jump'] = function()
            return PlayerJumpState(player, gravityAmount)
        end,
        ['falling'] = function()
            return PlayerFallingState(player, gravityAmount)
        end
    }
end

-- Initialize snail state machine
local function initSnailStateMachine(tileMap, player, snail)
    return StateMachine {
        ['idle'] = function()
            return SnailIdleState(tileMap, player, snail)
        end,
        ['moving'] = function()
            return SnailMovingState(tileMap, player, snail)
        end,
        ['chasing'] = function()
            return SnailChasingState(tileMap, player, snail)
        end
    }
end

PlayState = Class {
    __includes = BaseState
}

function PlayState:enter(params)
    print('Score: ' .. tostring(params.score))
    print('Level width: ' .. tostring(params.levelWidth))
    self.levelWidth = params.levelWidth or 100

    self.level = LevelMaker.generate(self.levelWidth, 10)
    self.tileMap = self.level.tileMap
    -- Find the first column with solid ground
    local spawnX = 0
    for x = 1, self.tileMap.width do
        local groundFound = false
        for y = 1, self.tileMap.height do
            if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                groundFound = true
                break
            end
        end
        if groundFound then
            spawnX = (x - 1) * TILE_SIZE
            break
        end
    end

    if params.player then
        print('Player exists! Updating player properties')
        self.player = params.player  -- Use the existing player object
        self.player.x = spawnX
        self.player.y = 0
        self.player.map = self.tileMap
        self.player.level = self.level
    else
        print('Creating new player')
        self.player = Player({
            x = spawnX,
            y = 0,
            width = 16,
            height = 20,
            score = 0,  -- Initialize the score here
            texture = 'green-alien',
            map = self.tileMap,
            level = self.level
        })
    end

    self.player.stateMachine = initPlayerStateMachine(self.player, self.gravityAmount)

    self:spawnEnemies()
    self.player:changeState('falling')
end

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.background = math.random(3)
    self.backgroundX = 0
    
    self.gravityOn = true
    self.gravityAmount = 6
end

function PlayState:update(dt)
    Timer.update(dt)
    self.level:clear()
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    drawBackground(self.background, self.backgroundX)
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    self.level:render()
    self.player:render()
    love.graphics.pop()

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.player.score), 4, 4)
    if (self.player.key) then
        love.graphics.draw(gTextures['keys-and-locks'], gFrames['keys-and-locks'][KEYS[self.player.key.color]],
            VIRTUAL_WIDTH / 2 + 16, 5)
    end
end

function PlayState:updateCamera()
    self.camX = math.max(0, math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - TILE_SIZE * 5)))
    self.backgroundX = (self.camX / 3) % 256
end

function PlayState:spawnEnemies()
    for x = 1, self.tileMap.width do
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    if math.random(20) == 1 then
                        -- Declare snail first
                        local snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16
                        }

                        -- Then initialize its state machine
                        snail.stateMachine = initSnailStateMachine(self.tileMap, self.player, snail)

                        snail:changeState('idle', {
                            wait = math.random(5)
                        })
                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end

