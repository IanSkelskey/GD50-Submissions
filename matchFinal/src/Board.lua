--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]] Board = Class {}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level or 1

    self:initializeTiles()
end

-- Initialize tiles on the board
function Board:initializeTiles()
    self.tiles = {}
    for y = 1, 8 do
        self.tiles[y] = {}
        for x = 1, 8 do
            self.tiles[y][x] = self:createRandomTile(x, y)
        end
    end
    self:removeInitialMatches()
end

-- Create a random tile
function Board:createRandomTile(x, y)
    local color = math.random(18)
    local variety = math.min(self.level, 6)
    return Tile(x, y, color, variety)
end

-- Remove initial matches
function Board:removeInitialMatches()
    if self:calculateMatches() then
        self:initializeTiles()
    end
end

-- Calculate matches on the board
function Board:calculateMatches()
    self.matches = {}
    self:findMatches("horizontal")
    self:findMatches("vertical")
    return #self.matches > 0 and self.matches or false
end

-- Find matches in a given direction
function Board:findMatches(direction)
    local length = 8
    for i = 1, length do
        local matchNum = 1
        local colorToMatch
        for j = 1, length do
            local x, y = j, i
            if direction == "vertical" then x, y = i, j end
            local tile = self.tiles[y][x]
            if j == 1 then
                colorToMatch = tile.color
            elseif tile.color == colorToMatch then
                matchNum = matchNum + 1
            else
                self:checkForMatch(x, y, matchNum, direction)
                colorToMatch = tile.color
                matchNum = 1
            end
        end
        self:checkForMatch(length + 1, i, matchNum, direction)
    end
end

-- Check for a match and add to matches table
function Board:checkForMatch(x, y, matchNum, direction)
    if matchNum >= 3 then
        local match = {tiles = {}, direction = direction}
        for i = 1, matchNum do
            local tileX, tileY = x - i, y
            if direction == "vertical" then tileX, tileY = x, y - i end
            table.insert(match.tiles, self.tiles[tileY][tileX])
        end
        table.insert(self.matches, match)
    end
end


-- Remove the matches from the Board
function Board:removeMatches()
    print("Starting to remove matches...")
    
    for _, match in pairs(self.matches) do
        print("Processing a match...")
        
        local shinyFound = false
        local shinyX, shinyY = 0, 0

        -- Check if any tile in the match is shiny
        for _, tile in pairs(match.tiles) do
            if tile.shiny then
                print("Shiny tile found!")
                
                shinyFound = true
                shinyX, shinyY = tile.gridX, tile.gridY
                break
            end
        end

        -- Remove matched tiles
        print("Removing matched tiles...")
        for _, tile in pairs(match.tiles) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end

        -- If a shiny tile was found, clear the entire row or column
        if shinyFound then
            print("Clearing entire row or column due to shiny tile...")
            
            if match.direction == "horizontal" then
                print("Clearing entire row...")
                for x = 1, 8 do
                    self.tiles[shinyY][x] = nil
                end
            else
                print("Clearing entire column...")
                for y = 1, 8 do
                    self.tiles[y][shinyX] = nil
                end
            end
        end
    end
    
    print("Matches removed. Resetting self.matches to nil.")
    self.matches = nil
end


--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set space back to 0, set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- Choose the color and variety based on the current level
                local color = math.random(18)
                local variety = 1
                if self.level > 1 then
                    variety = math.random(self.level, 6) -- Change as per your discretion
                end

                local tile = Tile(x, y, color, variety)
                tile.y = -32
                self.tiles[y][x] = tile

                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:getNewTiles()
    return {}
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
