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
            objects = addLevelFeatures(x, blockHeight, objects, tiles, tileID, true, tileset, topperset)
        else
            fillColumn(tiles, x, 7, height, tileID, nil, tileset, topperset)
        end
    end

    replaceJumpBlockWithLock(objects, LOCK_COLOR)
    placeKeyInJumpBlock(objects, LOCK_COLOR)

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
        local onCollide = function(obj)
            -- spawn a gem if we haven't already hit the block
            if not obj.hit then

                -- chance to spawn gem, not guaranteed
                if math.random(5) == 1 then

                    -- maintain reference so we can set it to nil
                    local gem = GameObject {
                        texture = 'gems',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE - 4,
                        width = 16,
                        height = 16,
                        frame = math.random(#GEMS),
                        collidable = true,
                        consumable = true,
                        solid = false,

                        -- gem has its own function to add to the player's score
                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            player.score = player.score + 100
                        end
                    }

                    -- make the gem move up from the block and play a sound
                    Timer.tween(0.1, {
                        [gem] = {
                            y = (blockHeight - 2) * TILE_SIZE
                        }
                    })
                    gSounds['powerup-reveal']:play()

                    table.insert(objects, gem)
                end

                obj.hit = true
            end

            gSounds['empty-block']:play()
        end

        table.insert(objects, GameObject {
            texture = 'jump-blocks',
            x = (x - 1) * TILE_SIZE,
            y = (blockHeight - 1) * TILE_SIZE,
            width = 16,
            height = 16,
            frame = math.random(#JUMP_BLOCKS),
            collidable = true,
            solid = true,
            onCollide = onCollide
        })
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
        objects[randomIndex] = GameObject {
            texture = 'keys-and-locks', -- Texture name
            x = selectedJumpBlock.x,
            y = selectedJumpBlock.y,
            width = 16,
            height = 16,
            frame = LOCKS[color],
            collidable = true,
            solid = true,
            onCollide = function(obj)
                -- Define behavior on collision
            end
        }
    else
        print("No jump blocks found to replace with a lock.")
    end
end

-- Function to place a key in a random jump block
function placeKeyInJumpBlock(objects, color)
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
        print("Frame for Key: ", KEYS[color])
        -- Step 3: Add Key
        -- Modify the onCollide function to spawn a key
        selectedJumpBlock.onCollide = function(obj)
            -- Existing code for spawning gems, etc., can remain here

            -- Add code to spawn a key that matches the LOCK_COLOR
            local key = GameObject {
                texture = 'keys-and-locks', -- Texture name
                x = selectedJumpBlock.x,
                y = selectedJumpBlock.y - 16, -- Position above the block
                width = 16,
                height = 16,
                frame = KEYS[color], -- Assuming KEYS is a table like LOCKS
                collidable = true,
                consumable = true,
                solid = false,
                onConsume = function(player, object)
                    -- Define behavior on consuming the key
                    -- For example, add the key to the player's inventory
                end
            }

            -- Add the key to the objects table
            table.insert(objects, key)
        end
    else
        print("No jump blocks found to place a key.")
    end
end
