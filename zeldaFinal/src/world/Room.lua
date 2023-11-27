--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]] Room = Class {}

-- Initialize Room
function Room:init(player)
    self:initDimensions()
    self:initTiles()
    self.entityManager = EntityManager(self)
    self:initObjects()
    self:initDoorways()
    self:initPlayer(player)
    self:initRenderOffsets()
end

-- Initialize dimensions
function Room:initDimensions()
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT
end

-- Initialize tiles
function Room:initTiles()
    self.tiles = {}
    self:generateWallsAndFloors()
end

-- Initialize objects
function Room:initObjects()
    self.objects = {}
    self:generateObjects()
end

-- Initialize doorways
function Room:initDoorways()
    self.doorways = {}
    self:generateDoorways()
end

-- Initialize player
function Room:initPlayer(player)
    self.player = player
end

-- Initialize render offsets
function Room:initRenderOffsets()
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

-- Get entities
function Room:getEntities()
    return self.entityManager.entities
end

-- Generate doorways
function Room:generateDoorways()
    local directions = {'top', 'bottom', 'left', 'right'}
    for _, dir in pairs(directions) do
        table.insert(self.doorways, Doorway(dir, false, self))
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    -- generate switch
    self:generateSwitch()

    -- generate pots
    self:generatePots()
end

function Room:generateSwitch()
    local switch = GameObject(GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
            VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16))
    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'

            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    table.insert(self.objects, switch)
    return switch
end

function Room:generatePots()
    local POTS_COUNT = math.random(1, 4)
    for i = 1, POTS_COUNT do
        local pot = GameObject(GAME_OBJECT_DEFS['pot'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) +
                MAP_RENDER_OFFSET_Y - TILE_SIZE - 16))
        table.insert(self.objects, pot)
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER

                -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end

            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

-- Update function
function Room:update(dt)
    if self:isSlidingToAnotherRoom() then
        return
    end

    self:updatePlayer(dt)
    self.entityManager:update(dt)
    self:updateObjects(dt)
end

-- Check if sliding to another room
function Room:isSlidingToAnotherRoom()
    return self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0
end

-- Update player
function Room:updatePlayer(dt)
    self.player:update(dt)
end

-- Check collision between player and entity
function Room:checkPlayerEntityCollision(entity)
    if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
        self:handlePlayerDamage()
    end
end

-- Handle player damage
function Room:handlePlayerDamage()
    gSounds['hit-player']:play()
    self.player:damage(1)
    self.player:goInvulnerable(1.5)

    if self.player.health == 0 then
        gStateMachine:change('game-over')
    end
end

-- Update objects
function Room:updateObjects(dt)
    for _, object in pairs(self.objects) do
        object:update(dt)
        if self.player:collides(object) then
            if object.onCollide then
                object:onCollide()
            end
        end
    end
end

-- Existing render function remains the same
function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX,
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    self.entityManager:render()

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()

        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE, -TILE_SIZE - 6,
            TILE_SIZE * 2, TILE_SIZE * 2 + 12)

        -- bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)

    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()

end
