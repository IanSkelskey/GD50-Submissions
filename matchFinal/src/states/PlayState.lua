--[[
    GD50
    Match-3 Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    State in which we can actually play, moving around a grid cursor that
    can swap two tiles; when two tiles make a legal swap (a swap that results
    in a valid match), perform the swap and destroy all matched tiles, adding
    their values to the player's point score. The player can continue playing
    until they exceed the number of points needed to get to the next level
    or until the time runs out, at which point they are brought back to the
    main menu or the score entry menu if they made the top 10.
]] PlayState = Class {
    __includes = BaseState
}

function PlayState:init()
    -- start our transition alpha at full, so we fade in
    self.transitionAlpha = 255 / 255

    -- position in the grid which we're highlighting
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    -- timer used to switch the highlight rect's color
    self.rectHighlighted = false

    -- flag to show whether we're able to process input (not swapping or clearing)
    self.canInput = true

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    self:initTimers()
end

function PlayState:initTimers()
    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    Timer.every(1, function()
        self.timer = self.timer - 1
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    -- grab level # from the params we're passed
    self.level = params.level

    -- spawn a board and place it toward the right
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16, self.level)

    -- grab score from params if it was passed
    self.score = params.score or 0

    -- score we have to reach to get to the next level
    self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)

    -- go back to start if time runs out
    if self.timer <= 0 then
        -- clear timers from prior PlayStates
        Timer.clear()

        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    -- go to next level if we surpass score goal
    if self.score >= self.scoreGoal then
        -- clear timers from prior PlayStates
        -- always clear before you change state, else next state's timers
        -- will also clear!
        Timer.clear()

        gSounds['next-level']:play()

        -- change to begin game state with new level (incremented)
        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    if self.canInput then
        self:handleInput()
    end

    Timer.update(dt)
end

function PlayState:handleInput()
    self:handleEscapeKey()
    self:handleMovementKeys()
    self:handleSkipLevelKey()
    self:handleTileSelection()
end

function PlayState:handleEscapeKey()
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:handleMovementKeys()
    if love.keyboard.wasPressed('up') then
        self:moveCursor(0, -1)
    elseif love.keyboard.wasPressed('down') then
        self:moveCursor(0, 1)
    elseif love.keyboard.wasPressed('left') then
        self:moveCursor(-1, 0)
    elseif love.keyboard.wasPressed('right') then
        self:moveCursor(1, 0)
    end
end

function PlayState:moveCursor(dx, dy)
    self.boardHighlightX = math.max(0, math.min(7, self.boardHighlightX + dx))
    self.boardHighlightY = math.max(0, math.min(7, self.boardHighlightY + dy))
    gSounds['select']:play()
end

function PlayState:handleSkipLevelKey()
    if love.keyboard.wasPressed('s') then
        Timer.clear()
        gSounds['next-level']:play()
        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end
end

function PlayState:handleTileSelection()
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local x = self.boardHighlightX + 1
        local y = self.boardHighlightY + 1

        if not self.highlightedTile then
            self.highlightedTile = self.board.tiles[y][x]
        elseif self.highlightedTile == self.board.tiles[y][x] then
            self.highlightedTile = nil
        elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
            gSounds['error']:play()
            self.highlightedTile = nil
        else
            self:swapTiles()
        end
    end
end

function PlayState:swapTiles()
    local tempX = self.highlightedTile.gridX
    local tempY = self.highlightedTile.gridY
    local x = self.boardHighlightX + 1
    local y = self.boardHighlightY + 1
    local newTile = self.board.tiles[y][x]
    local highlightedTile = self.highlightedTile  -- Store the highlighted tile

    self.highlightedTile.gridX = newTile.gridX
    self.highlightedTile.gridY = newTile.gridY
    newTile.gridX = tempX
    newTile.gridY = tempY

    self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
    self.board.tiles[newTile.gridY][newTile.gridX] = newTile

    Timer.tween(0.1, {
        [self.highlightedTile] = {x = newTile.x, y = newTile.y},
        [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
    }):finish(function()
        local matches = self:calculateMatches()
        if not matches then
            self:swapBack(tempX, tempY, newTile, highlightedTile)  -- Pass the stored highlighted tile
        end
    end)
end

function PlayState:swapBack(tempX, tempY, newTile, highlightedTile)  -- Add highlightedTile as an argument
    -- Swap the grid positions back
    highlightedTile.gridX = tempX  -- Use the passed highlightedTile
    highlightedTile.gridY = tempY
    newTile.gridX = highlightedTile.gridX
    newTile.gridY = highlightedTile.gridY

    -- Swap the tiles back in the tiles table
    self.board.tiles[highlightedTile.gridY][highlightedTile.gridX] = highlightedTile  -- Use the passed highlightedTile
    self.board.tiles[newTile.gridY][newTile.gridX] = newTile

    -- Tween the coordinates back
    Timer.tween(0.1, {
        [highlightedTile] = {x = newTile.x, y = newTile.y},  -- Use the passed highlightedTile
        [newTile] = {x = highlightedTile.x, y = highlightedTile.y}
    }):finish(function()
        self.canInput = true
    end)
end


--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
    self.highlightedTile = nil

    -- if we have any matches, remove them and tween the falling blocks that result
    local matches = self.board:calculateMatches()

    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

        -- remove any tiles that matched from the board, making empty spaces
        local tilesRemoved = self.board:removeMatches()
        self.score = self.score + tilesRemoved * 50 -- Update the score
        self.timer = self.timer + tilesRemoved -- Update the timer

        -- gets a table with tween values for tiles that should now fall
        local tilesToFall = self.board:getFallingTiles()

        -- first, tween the falling tiles over 0.25s
        Timer.tween(0.25, tilesToFall):finish(function()
            local newTiles = self.board:getNewTiles()

            -- then, tween new tiles that spawn from the ceiling over 0.25s to fill in
            -- the new upper gaps that exist
            Timer.tween(0.25, newTiles):finish(function()
                -- recursively call function in case new matches have been created
                -- as a result of falling blocks once new blocks have finished falling
                self:calculateMatches()
            end)
        end)
        -- if no matches, we can continue playing
    else
        self.canInput = true
    end
end

function PlayState:render()
    -- render board of tiles
    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then
        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 96 / 255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end

    -- render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217 / 255, 87 / 255, 99 / 255, 255 / 255)
    else
        love.graphics.setColor(172 / 255, 50 / 255, 50 / 255, 255 / 255)
    end

    -- draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272), self.boardHighlightY * 32 + 16,
        32, 32, 4)

    -- GUI text
    love.graphics.setColor(56 / 255, 56 / 255, 56 / 255, 234 / 255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99 / 255, 155 / 255, 255 / 255, 255 / 255)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end
