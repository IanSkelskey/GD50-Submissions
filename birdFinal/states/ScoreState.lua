--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
local DIAMOND_IMAGE = love.graphics.newImage('diamond.png')
local PLATINUM_IMAGE = love.graphics.newImage('platinum.png')
local GOLD_IMAGE = love.graphics.newImage('gold.png')
local SILVER_IMAGE = love.graphics.newImage('silver.png')
local BRONZE_IMAGE = love.graphics.newImage('bronze.png')

function ScoreState:init()
    fromStart = true
    scrolling = true
end

function ScoreState:enter(params)
    score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    if score > 199 then
      love.graphics.setFont(flappyFont)
      love.graphics.printf('DIAMOND', 0, 32, VIRTUAL_WIDTH, 'center')
      DIAMOND_IMAGE:setFilter("nearest","nearest")
      love.graphics.draw(DIAMOND_IMAGE, VIRTUAL_WIDTH/2 - 32, 80, 0, 4, 4)
    elseif score > 99 then
      love.graphics.setFont(flappyFont)
      love.graphics.printf('PLATINUM', 0, 32, VIRTUAL_WIDTH, 'center')
      PLATINUM_IMAGE:setFilter("nearest","nearest")
      love.graphics.draw(PLATINUM_IMAGE, VIRTUAL_WIDTH/2 - 32, 80, 0, 4, 4)
    elseif score > 49 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('GOLD', 0, 32, VIRTUAL_WIDTH, 'center')
        GOLD_IMAGE:setFilter("nearest","nearest")
        love.graphics.draw(GOLD_IMAGE, VIRTUAL_WIDTH/2 - 32, 80, 0, 4, 4)
    elseif score > 24 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('SILVER', 0, 32, VIRTUAL_WIDTH, 'center')
        SILVER_IMAGE:setFilter("nearest","nearest")
        love.graphics.draw(SILVER_IMAGE, VIRTUAL_WIDTH/2 - 32, 80, 0, 4, 4)
    elseif score > 9 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('BRONZE', 0, 32, VIRTUAL_WIDTH, 'center')
        BRONZE_IMAGE:setFilter("nearest","nearest")
        love.graphics.draw(BRONZE_IMAGE, VIRTUAL_WIDTH/2 - 32, 80, 0, 4, 4)
    else
        love.graphics.setFont(flappyFont)
        love.graphics.printf('No medal this time. Keep trying!', 0, 32, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(score), 0, VIRTUAL_HEIGHT - 112, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to Play Again!', 0, VIRTUAL_HEIGHT - 48, VIRTUAL_WIDTH, 'center')
end

function ScoreState:exit()
    scrolling = true

end
