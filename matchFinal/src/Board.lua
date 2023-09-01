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

function Board:initializeTiles()
    self.tiles = {}

    for y = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for x = 1, 8 do
            -- generate random colors and varieties based on the level
            local color = math.random(18)

            -- Choose variety based on the level
            local variety = 1
            if self.level > 1 then
                -- Get the minimum value between self.level and 6

                local varietyLimit = math.min(self.level, 6)

                variety = math.random(1, varietyLimit) -- Change as per your discretion
            end

            -- create a new tile at X, Y with that color and variety
            table.insert(self.tiles[y], Tile(x, y, color, variety))
        end
    end

    while self:calculateMatches() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}
    local matchNum = 1

    -- Horizontal matches
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1
        for x = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}
                    match.matchType = "horizontal"
                    for x2 = x - 1, x - matchNum, -1 do
                        table.insert(match, self.tiles[y][x2])
                    end

                    local containsShiny = false
                    for _, tile in pairs(match) do
                        if tile.shiny then
                            containsShiny = true
                            break
                        end
                    end

                    if containsShiny then
                        for col = 1, 8 do
                            table.insert(match, self.tiles[y][col])
                        end
                        
                    end

                    table.insert(matches, match)
                end

                if x >= 7 then
                    break
                end

                matchNum = 1
            end
        end

        if matchNum >= 3 then
            local match = {}
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- Vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}
                    match.matchType = "vertical"
                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    local containsShiny = false
                    for _, tile in pairs(match) do
                        if tile.shiny then
                            containsShiny = true
                            break
                        end
                    end

                    if containsShiny then
                        for row = 1, 8 do
                            table.insert(match, self.tiles[row][x])
                        end
                        
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                if y >= 7 then
                    break
                end
            end
        end

        if matchNum >= 3 then
            local match = {}
            for y = 8, 8 - matchNum, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    self.matches = matches

    return #self.matches > 0 and self.matches or false
end


--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for _, match in pairs(self.matches) do
        print(match.matchType)
        for _, tile in pairs(match) do
            print(tile)
            print(tile.gridX, tile.gridY)
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end
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
