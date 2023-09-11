LevelMaker = Class {}

-- Constants
local PILLAR_HEIGHT = 2
local BLOCK_HEIGHT = 4
local BUSH_HEIGHT = 6

-- Helper function to create a new tile
local function createTile(x, y, tileID, topper, tileset, topperset)
    return Tile(x, y, tileID, topper, tileset, topperset)
end

-- Helper function to initialize tiles
local function initializeTiles(height)
    local tiles = {}
    for x = 1, height do
        table.insert(tiles, {})
    end
    return tiles
end

-- Helper function to fill a column with tiles
local function fillColumn(tiles, x, startY, endY, tileID, topper, tileset, topperset)
    for y = startY, endY do
        table.insert(tiles[y], createTile(x, y, tileID, y == startY and topper or nil, tileset, topperset))
    end
end

-- Function to add a pillar
local function addPillar(x, objects, tileID, topper, tiles, tileset, topperset)
    tiles[5][x] = createTile(x, 5, tileID, topper, tileset, topperset)
    tiles[6][x] = createTile(x, 6, tileID, nil, tileset, topperset)
    tiles[7][x].topper = nil
end

-- Function to add a bush
local function addBush(x, y, objects)
    local bush = Bush(x, y)
    table.insert(objects, bush)
end

-- Function to add a random block
local function addRandomBlock(x, y, objects, eventManager)
    local block = Block(x, y, nil, eventManager)
    if math.random(5) == 1 then
        block.reward = Gem(block.x, block.y - 12)
    end
    table.insert(objects, block)
end

-- Main function to generate the level
function LevelMaker.generate(width, height)
    local tiles = initializeTiles(height)
    local entities = {}
    local objects = {}

    -- event manager for world events
    local eventManager = EventManager()

    -- Subscribe to 'blockHit' event
    eventManager:subscribe('blockHit', function(reward)
        if reward then
            table.insert(objects, reward)
        end
    end)

    eventManager:subscribe('keyConsume', function(color)
        unlockBlock(objects, color)
        print('Something happened!')
    end)

    local tileset = math.random(20)
    local topperset = math.random(20)
    local LOCK_COLOR = math.random(#KEYS)

    -- Generate the level column by column
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        local blockHeight = 4

        -- Create empty space
        fillColumn(tiles, x, 1, 6, tileID, nil, tileset, topperset)

        -- Randomly decide to create ground or keep it empty
        if math.random(7) ~= 1 then
            tileID = TILE_ID_GROUND
            fillColumn(tiles, x, 7, height, tileID, true, tileset, topperset)
            objects = addLevelFeatures(x, objects, tiles, tileID, true, tileset, topperset, eventManager)
        else
            fillColumn(tiles, x, 7, height, tileID, nil, tileset, topperset)
        end
    end

    replaceJumpBlockWithLock(objects, LOCK_COLOR)
    placeKeyInJumpBlock(objects, LOCK_COLOR, eventManager)

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end

-- Function to add features like pillars, bushes, and blocks
function addLevelFeatures(x, objects, tiles, tileID, topper, tileset, topperset, eventManager)
    local hasPillar = math.random(8) == 1
    local hasBush = math.random(8) == 1
    local hasBlock = math.random(10) == 1

    if hasPillar then
        addPillar(x, objects, tileID, topper, tiles, tileset, topperset)
    end

    if hasBush then
        local x = (x - 1) * TILE_SIZE
        local y
        if (hasPillar) then
            print('Generating bush on pillar at x: ', x)
            y = TILE_SIZE * 3
        else
            print('Generating bush without pillar at x: ', x)
            y = TILE_SIZE * 5
        end
        addBush(x, y, objects)
    end

    if hasBlock then
        local x = (x - 1) * TILE_SIZE
        local y
        if (hasPillar) then
            print('Generating block on pillar at x: ', x)
            y = (PILLAR_HEIGHT - 1) * TILE_SIZE
        else
            print('Generating block without pillar at x: ', x)
            y = (BLOCK_HEIGHT - 1) * TILE_SIZE
        end
        addRandomBlock(x, y, objects, eventManager)
    end

    return objects
end

-- Function to replace a random jump block with a lock
function replaceJumpBlockWithLock(objects, color)
    -- Step 1: Identify Jump Blocks
    local jumpBlockIndices = {}
    for i, object in ipairs(objects) do
        if object.texture == 'jump-blocks' then
            table.insert(jumpBlockIndices, i)
        end
    end

    if #jumpBlockIndices > 0 then
        local randomIndex = jumpBlockIndices[math.random(#jumpBlockIndices)]
        local selectedJumpBlock = objects[randomIndex]
        print("Frame for Lock: ", LOCKS[color])
        objects[randomIndex] = Lock(selectedJumpBlock.x, selectedJumpBlock.y - 16, color, eventManager)
    else
        print("No jump blocks found to replace with a lock.")
    end
end

-- Function to place a key in a random jump block
function placeKeyInJumpBlock(objects, color, eventManager)
    -- Step 1: Identify Jump Blocks
    local jumpBlockIndices = {}
    for i, object in ipairs(objects) do
        if object.texture == 'jump-blocks' then
            table.insert(jumpBlockIndices, i)
        end
    end

    -- Step 2: Random Selection
    if #jumpBlockIndices > 0 then
        local randomIndex = jumpBlockIndices[math.random(#jumpBlockIndices)]
        local selectedJumpBlock = objects[randomIndex]
        selectedJumpBlock.reward = Key(selectedJumpBlock.x, selectedJumpBlock.y - 16, color, eventManager)
    else
        print("No jump blocks found to place a key.")
    end
end

-- Unlock the locked block by making it consumable
function unlockBlock(objects, color)
    -- Step 1: Identify Locked Blocks
    local lockedBlockIndex
    for i, object in ipairs(objects) do
        if object.texture == 'keys-and-locks' and object.frame == LOCKS[color] then
            lockedBlockIndex = i
        end
    end

    local selectedLockedBlock = objects[lockedBlockIndex]
    selectedLockedBlock.consumable = true
    selectedLockedBlock.solid = false

end
