LevelMaker = Class {}

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
            objects = addLevelFeatures(x, blockHeight, objects, tiles, tileID, true, tileset, topperset, eventManager)
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
function addLevelFeatures(x, blockHeight, objects, tiles, tileID, topper, tileset, topperset, eventManager)
    if math.random(8) == 1 then
        -- Add pillar
        blockHeight = 2
        tiles[5][x] = createTile(x, 5, tileID, topper, tileset, topperset)
        tiles[6][x] = createTile(x, 6, tileID, nil, tileset, topperset)
        tiles[7][x].topper = nil

        -- Randomly add bush on pillar
        if math.random(8) == 1 then
            table.insert(objects, GameObject {
                texture = 'bushes',
                x = (x - 1) * TILE_SIZE,
                y = (4 - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                collidable = false,
                solid = false
            })
        end
    elseif math.random(8) == 1 then
        -- Add bush
        table.insert(objects, GameObject {
            texture = 'bushes',
            x = (x - 1) * TILE_SIZE,
            y = (6 - 1) * TILE_SIZE,
            width = 16,
            height = 16,
            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
            collidable = false,
            solid = false
        })
    end

    -- Randomly spawn a block
    if math.random(10) == 1 then
        local block = Block((x - 1) * TILE_SIZE, (blockHeight - 1) * TILE_SIZE, nil, eventManager)
        if math.random(5) == 1 then
            block.reward = Gem(block.x, block.y - 12)
        end
        table.insert(objects, block)
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
