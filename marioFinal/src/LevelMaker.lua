-- LevelMaker Class
LevelMaker = Class{}

-- Helper function to create a new tile
local function createTile(x, y, tileID, topper, tileset, topperset)
    return Tile(x, y, tileID, topper, tileset, topperset)
end

-- Helper function to create a new GameObject
local function createObject(texture, x, y, width, height, frame, collidable, solid, onCollide)
    return {
        texture = texture,
        x = x,
        y = y,
        width = width,
        height = height,
        frame = frame,
        collidable = collidable,
        solid = solid,
        onCollide = onCollide
    }
end

-- Main function to generate the level
function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- Initialize tiles
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- Generate the level column by column
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        local blockHeight = 4

        -- Create empty space
        for y = 1, 6 do
            table.insert(tiles[y], createTile(x, y, tileID, nil, tileset, topperset))
        end

        -- Randomly decide to create ground or keep it empty
        if math.random(7) ~= 1 then
            tileID = TILE_ID_GROUND

            -- Create ground tiles
            for y = 7, height do
                table.insert(tiles[y], createTile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- Randomly add features to the level
            blockHeight, objects = addLevelFeatures(x, blockHeight, objects, tiles, tileID, topper, tileset, topperset)
        else
            -- Create empty space
            for y = 7, height do
                table.insert(tiles[y], createTile(x, y, tileID, nil, tileset, topperset))
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end

-- Function to add features like pillars, bushes, and blocks
function addLevelFeatures(x, blockHeight, objects, tiles, tileID, topper, tileset, topperset)
    if math.random(8) == 1 then
        -- Add pillar
        blockHeight = 2
        tiles[5][x] = createTile(x, 5, tileID, topper, tileset, topperset)
        tiles[6][x] = createTile(x, 6, tileID, nil, tileset, topperset)
        tiles[7][x].topper = nil

        -- Randomly add bush on pillar
        if math.random(8) == 1 then
            table.insert(objects, createObject('bushes', (x - 1) * TILE_SIZE, (4 - 1) * TILE_SIZE, 16, 16, BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7, false, false, nil))
        end
    elseif math.random(8) == 1 then
        -- Add bush
        table.insert(objects, createObject('bushes', (x - 1) * TILE_SIZE, (6 - 1) * TILE_SIZE, 16, 16, BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7, false, false, nil))
    end

    -- Randomly spawn a block
    if math.random(10) == 1 then
        local onCollide = function(obj)
            -- Define behavior on collision
        end

        table.insert(objects, createObject('jump-blocks', (x - 1) * TILE_SIZE, (blockHeight - 1) * TILE_SIZE, 16, 16, math.random(#JUMP_BLOCKS), true, true, onCollide))
    end

    return blockHeight, objects
end
